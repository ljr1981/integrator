note
	description: "[
		Representation of an ECF with Clients and Suppliers ECFs.
		]"

class
	IG_ECF_CLIENT_SUPPLIER

inherit
	ANY
		redefine
			out
		end

feature -- Access

	name: STRING
			-- `ecf_name' of Current {IG_ECF_CLIENT_SUPPLIER}.
		attribute
			create Result.make_empty
		end

	description: STRING
			-- `description' of Current {IG_ECF_CLIENT_SUPPLIER}.
		attribute
			create Result.make_empty
		end

	path:  PATH
			-- `ecf_path' to `ecf_name' of Current {IG_ECF_CLIENT_SUPPLIER}.
		attribute
			create Result.make_empty
		end

	github_path:  PATH
			-- `github_path' of Current {IG_ECF_CLIENT_SUPPLIER}.
		attribute
			create Result.make_empty
		end

	github_config_path:  PATH
			-- `github_config_path' of Current {IG_ECF_CLIENT_SUPPLIER}.
		attribute
			create Result.make_empty
		end

	uuid: UUID
			-- `uuid' of Current {IG_ECF_CLIENT_SUPPLIER}.
		attribute
			create Result
		end

	clients: attached like list_anchor
			-- `clients' of Current {IG_ECF_CLIENT_SUPPLIER}.
		note
			design: "[
				These are loaded by the `set_possible_client' feature
				below. Please see its "notes" part for more information.
				]"
		attribute
			create Result.make (10)
		end

	suppliers: attached like list_anchor
			-- `suppliers' of Current {IG_ECF_CLIENT_SUPPLIER}.
		note
			design: "[
				These are loaded from the ECF XML specification.
				]"
		attribute
			create Result.make (10)
		end

feature -- Settings

	set_name (a_item: like name)
			-- `set_name' with `a_item'.
		do
			name := a_item
		end

	set_description (a_item: like description)
			-- `set_description' with `a_item'.
		do
			description := a_item
		end

	set_path (a_item: like path)
			-- `set_path' with `a_item'.
		do
			path := a_item
		end

	set_github_path (a_item: like github_path)
			-- `set_github_path' with `a_item'.
		do
			github_path := a_item
		end

	set_github_config_path (a_item: like github_config_path)
			-- `set_github_config_path' with `a_item'.
		do
			github_config_path := a_item
		end

	set_uuid (a_item: like uuid)
			-- `set_uuid' with `a_item'.
		do
			uuid := a_item
		end

	set_possible_client (a_possible_client: IG_ECF_CLIENT_SUPPLIER)
			-- `set_possible_client' from `a_possible_client'.
		note
			design: "[
				Suppliers are already defined in the ECF file. Our list of
				`suppliers' is built from the data in the ECF.
				
				From there, `a_possible_client' is passed in. We look on
				`a_possible_client's `suppliers' list to see if we are on it.
				If so, we put `a_possible_client' on our list of `clients'.
				]"
		local
			l_uuid: STRING
		do
			if attached uuid as al_supplier_uuid and then attached al_supplier_uuid.out as al_supplier_uuid_string then
				if attached a_possible_client.suppliers as al_possible_client_suppliers then
					across
						al_possible_client_suppliers as ic_possible_client_suppliers
					loop
						if attached ic_possible_client_suppliers.item.uuid as al_possible_client_suppliers_uuid then
							if al_possible_client_suppliers_uuid.out.same_string (al_supplier_uuid_string) then
								clients.force (a_possible_client, a_possible_client.uuid.out)
							end
						end
					end
				end
			end
		end

feature -- Status Report

	is_github_based: BOOLEAN
			-- `is_github_based'?
		do
			Result := (create {DIRECTORY}.make_with_path (github_path)).exists
		end

	has_github_suppliers: BOOLEAN
			-- `has_github_suppliers'?
		do
			Result := is_github_based and then not across suppliers as ic_suppliers some ic_suppliers.item.is_github_based end
		end

	has_github_clients: BOOLEAN
			-- `has_github_clients'?
		do
			Result := is_github_based and then across clients as ic_clients some ic_clients.item.is_github_based end
		end

	is_trunk: BOOLEAN
		do
			Result := is_github_based and then (not has_github_suppliers and then has_github_clients)
		end

	is_branch: BOOLEAN
		do
			Result := is_github_based and then (has_github_suppliers and has_github_clients)
		end

	is_leaf: BOOLEAN
			-- `is_branch'?
		do
			Result := is_github_based and then (has_github_suppliers and not has_github_clients)
		end

feature -- Outputs

	out: STRING_8
			-- <Precursor>
		do
			create Result.make_empty
			Result.append_string ("Name: ")
			Result.append_string (name)
			Result.append_character ('%N')

			Result.append_string ("Path: ")
			Result.append_string (path.name.out)
			Result.append_character ('%N')

			Result.append_string ("UUID: ")
			Result.append_string (uuid.out)
			Result.append_character ('%N')
			Result.append_character ('%N')

			Result.append_string ("Clients:")
			Result.append_character ('%N')
			Result.append_character ('%N')
			if attached clients as al_item and then al_item.count > 0  then
				across
					clients as ic_clients
				loop
					Result.append_character ('%T')
					Result.append_string ("Name: ")
					Result.append_string (ic_clients.item.name.out)
					Result.append_character ('%N')

					Result.append_character ('%T')
					Result.append_string ("Path: ")
					Result.append_string (ic_clients.item.path.name.out)
					Result.append_character ('%N')

					Result.append_character ('%T')
					Result.append_string ("UUID: ")
					Result.append_string (ic_clients.item.uuid.out)
					Result.append_character ('%N')
				end
			end

			Result.append_character ('%N')
			Result.append_string ("Suppliers:")
			Result.append_character ('%N')
			Result.append_character ('%N')
			if attached suppliers as al_item and then al_item.count > 0  then
				across
					suppliers as ic_suppliers
				loop
					Result.append_character ('%T')
					Result.append_string ("Name: ")
					Result.append_string (ic_suppliers.item.name.out)
					Result.append_character ('%N')

					Result.append_character ('%T')
					Result.append_string ("Path: ")
					Result.append_string (ic_suppliers.item.path.name.out)
					Result.append_character ('%N')

					Result.append_character ('%T')
					Result.append_string ("UUID: ")
					Result.append_string (ic_suppliers.item.uuid.out)
					Result.append_character ('%N')
				end
			end
		end

feature {NONE} -- Implementation: Anchors

	list_anchor: detachable HASH_TABLE [IG_ECF_CLIENT_SUPPLIER, STRING]
			-- `list_anchor' for `clients' and `suppliers'.

end
