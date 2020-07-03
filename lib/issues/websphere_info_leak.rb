module Intrigue
module Issue
class WebsphereInfoLeak < BaseIssue

  def self.generate(instance_details={})
    {
      name: "websphere_info_leak",
      pretty_name: "Websphere Info Leak",
      identifiers: [],
      severity: 2,
      category: "vulnerability",
      status: "confirmed",
      description: "This server is exposing sensitive paths.",
      remediation: "Block access to these paths.",
      affected_software: [
        { :vendor => "IBM", :product => "Websphere" }
      ],
      references: [],
      check: "uri_brute_focused_content"
    }.merge!(instance_details)
  end

end
end
end