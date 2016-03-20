note
	description: "[
		Documentation and General Notes for Application.
		]"

deferred class
	IG_DOCS

feature -- Documentation

	-- "When designing, start with the outputs and work backwards."

	clients_and_suppliers
		note
			design: "[
				Goal: Each ECF has a list of Clients and Suppliers.
				
				Backstep: What does a list consist of (Client or Supplier)?
					(1) System ECF file name (blah.ecf) (plus fully qualified path) -> derive a PATH
						(1a) GITHUB PATHs can be computed as fully qualified.
						(1b) All others cannot (possibly). Would require possibly 
								unavailable sources (e.g. registry in Windows)
					(2)	System name (possibly redirected)
					(3) System UUID (possibly computed)
					(4) 
				]"
		deferred
		end

end
