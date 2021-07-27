module Intrigue
  module Task
    class GatherGitlabProjects < BaseTask
      def self.metadata
        {
          name: 'gather_gitlab_projects',
          pretty_name: 'Gather Gitlab Projects',
          authors: ['maxim'],
          description: 'Uses the Gitlab API to pull all known repositories for a GitlabAccount.',
          references: ['https://docs.gitlab.com/ee/api/'],
          type: 'discovery',
          passive: false,
          allowed_types: ['GitlabAccount'],
          example_entities: [{ 'type' => 'GitlabAccount', 'details' => { 'name' => 'intrigueio' } }],
          allowed_options: [
            { name: 'gitlab_instance_uri', regex: 'alpha_numeric_list', default: 'https://gitlab.com' }
          ],
          created_types: ['GitlabProject']
        }
      end

      # ADD RATE LIMIT CHECK

      ## Default method, subclasses must override this
      def run
        super
        account_name = _get_entity_name
        gitlab_host = _get_option('gitlab_instance_uri')

        results = retrieve_repositories(account_name, gitlab_host)
        return if results.nil?

        _log "#{account_name} has no projects" if results.empty?
        return if results.empty?

        _log_good "Obtained #{results.size} projects belonging to #{account_name}."

        results.each { |r| create_project_entity(r, gitlab_host) }
      end

      def retrieve_repositories(name, host)
        # if token is nil ; set to empty since gitlab will ignore empty value in private-token header
        access_token = retrieve_gitlab_token || ''
        headers = { 'PRIVATE-TOKEN' => access_token } if access_token

        uri = if group?(name, access_token)
                "#{host}/api/v4/groups/#{name}/projects"
              else
                "#{host}/api/v4/users/#{name}/projects"
              end

        total_pages = http_request(:get, "#{uri}?per_page=100", nil, headers).headers['x-total-pages']

        if total_pages.nil?
          _log "No account or group with the name #{name} exists."
          return nil
        end

        results = (1..total_pages.to_i).map do |p|
          _log "Obtaining results for Page #{p}."
          json_result = http_get_body("#{uri}?page=#{p}&per_page=100", nil, headers)
          parse_results(json_result)
        end

        results.flatten
      end

      def parse_results(json_blob)
        begin
          parsed_json = JSON.parse(json_blob)
        rescue JSON::ParserError
          _log_error 'Unable to parse JSON'
          return nil
        end

        repositories = parsed_json.map { |item| item['path_with_namespace'] }
        repositories
      end

      def create_project_entity(project, host)
        _create_entity 'GitlabProject', {
          'name' => project,
          'project_name' => project,
          'uri' => "#{host}/#{project}"
        }
      end
    end
  end
end