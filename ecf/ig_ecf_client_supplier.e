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

	name: CA_PRIMITIVE [STRING]
			-- `ecf_name' of Current {IG_ECF_CLIENT_SUPPLIER}.
		attribute
			create Result
		end

	path:  CA_PRIMITIVE [PATH]
			-- `ecf_path' to `ecf_name' of Current {IG_ECF_CLIENT_SUPPLIER}.
		attribute
			create Result
		end

	uuid: CA_PRIMITIVE [UUID]
			-- `uuid' of Current {IG_ECF_CLIENT_SUPPLIER}.
		attribute
			create Result
		end

	clients: CA_PRIMITIVE [attached like list_anchor]
			-- `clients' of Current {IG_ECF_CLIENT_SUPPLIER}.
		note
			design: "[
				These are loaded by the `set_possible_client' feature
				below. Please see its "notes" part for more information.
				]"
		attribute
			create Result
		end

	suppliers: CA_PRIMITIVE [attached like list_anchor]
			-- `suppliers' of Current {IG_ECF_CLIENT_SUPPLIER}.
		note
			design: "[
				These are loaded from the ECF XML specification.
				]"
		attribute
			create Result
		end

feature -- Settings

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
		do
			if a_possible_client.suppliers.attached_item.has (Current.uuid.attached_item) then
				if not attached clients.item then
					clients.set_item (create {like clients.item}.make (1))
				end
				clients.attached_item.force (a_possible_client, a_possible_client.uuid.attached_item)
			end
		end

feature -- Outputs

	out: STRING_8
			-- <Precursor>
		do
			create Result.make_empty
			Result.append_string ("Name: ")
			Result.append_string (name.attached_item)
			Result.append_character ('%N')

			Result.append_string ("Path: ")
			Result.append_string (path.attached_item.name.out)
			Result.append_character ('%N')

			Result.append_string ("UUID: ")
			Result.append_string (uuid.attached_item.out)
			Result.append_character ('%N')
			Result.append_character ('%N')

			Result.append_string ("Clients:")
			Result.append_character ('%N')
			Result.append_character ('%N')
			if attached clients.item as al_item and then al_item.count > 0  then
				across
					clients.attached_item as ic_clients
				loop
					Result.append_character ('%T')
					Result.append_string ("Name: ")
					Result.append_string (ic_clients.item.name.attached_item.out)
					Result.append_character ('%N')

					Result.append_character ('%T')
					Result.append_string ("Path: ")
					Result.append_string (ic_clients.item.path.attached_item.name.out)
					Result.append_character ('%N')

					Result.append_character ('%T')
					Result.append_string ("UUID: ")
					Result.append_string (ic_clients.item.uuid.attached_item.out)
					Result.append_character ('%N')
				end
			end

			Result.append_character ('%N')
			Result.append_string ("Suppliers:")
			Result.append_character ('%N')
			Result.append_character ('%N')
			if attached suppliers.item as al_item and then al_item.count > 0  then
				across
					suppliers.attached_item as ic_suppliers
				loop
					Result.append_character ('%T')
					Result.append_string ("Name: ")
					Result.append_string (ic_suppliers.item.name.attached_item.out)
					Result.append_character ('%N')

					Result.append_character ('%T')
					Result.append_string ("Path: ")
					Result.append_string (ic_suppliers.item.path.attached_item.name.out)
					Result.append_character ('%N')

					Result.append_character ('%T')
					Result.append_string ("UUID: ")
					Result.append_string (ic_suppliers.item.uuid.attached_item.out)
					Result.append_character ('%N')
				end
			end
		end

feature {NONE} -- Implementation: Anchors

	list_anchor: detachable HASH_TABLE [IG_ECF_CLIENT_SUPPLIER, UUID]
			-- `list_anchor' for `clients' and `suppliers'.

end
