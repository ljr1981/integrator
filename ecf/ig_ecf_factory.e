note
	description: "Summary description for {IG_ECF_FACTORY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	IG_ECF_FACTORY

feature -- Basic Operations

	new_ecf_from_file (a_path: PATH): IG_ECF
		local
			l_callbacks: IG_ECF_XML_CALLBACKS
			l_parser: XML_CUSTOM_PARSER
		do
			create l_callbacks.make
			l_parser := (create {XML_PARSER_FACTORY}).new_custom_parser
			l_parser.set_callbacks (l_callbacks)
			l_parser.parse_from_path (a_path)
			check attached l_callbacks.ecf_client_supplier as al_ecf then
				Result := al_ecf
				al_ecf.set_path (a_path.parent)
				check attached l_callbacks.targets as al_targets then across al_targets as ic_targets loop al_ecf.targets.force (ic_targets.item) end end
			end
		end

end
