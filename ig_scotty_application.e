note
	description: "[
		Representation of a root application as {IG_SCOTTY_APPLICATION}
		]"

class
	IG_SCOTTY_APPLICATION

inherit
	ARGUMENTS

	IG_ANY

create
	make

feature {NONE} -- Initialization

	make
			-- `make' initialization.
		local
			l_scanner: IG_ECF_SCANNER
			l_ecf: IG_ECF
		do
			create l_scanner
			print ("scanning ...%N")
			l_scanner.scan_github
			print ("building `comiple.cmd' outputs for each path%N")
			l_scanner.output_compile_cmd
		end

end
