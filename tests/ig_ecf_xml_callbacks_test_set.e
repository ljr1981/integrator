note
	description: "Tests of {IG_ECF_XML_CALLBACKS}."
	testing: "type/manual"

class
	IG_ECF_XML_CALLBACKS_TEST_SET

inherit
	EQA_TEST_SET
		rename
			assert as assert_old
		end

	EQA_COMMONLY_USED_ASSERTIONS
		undefine
			default_create
		end

feature -- Test routines

	sample_ecf_tests_2
		local
			l_callbacks: IG_ECF_XML_CALLBACKS
			l_parser: XML_LITE_PARSER
			l_count: INTEGER
			l_ecf_client_supplier: detachable IG_ECF
		do
			create l_callbacks.make
			l_parser := (create {XML_LITE_PARSER_FACTORY}).new_parser
			l_parser.set_callbacks (l_callbacks)
			l_parser.parse_from_string (sample_ecf)
			l_ecf_client_supplier := l_callbacks.ecf_client_supplier

			if attached l_ecf_client_supplier then
					-- System Name, UUID, Description
				assert_strings_equal ("system_name", "integrator", l_ecf_client_supplier.name)
				if attached l_ecf_client_supplier.uuid.out as al_item then
					assert_strings_equal ("system_uuid", "4044DD19-B545-FAE6-1541-00005FD08DC5", al_item)
				end
				assert_strings_equal ("descritption_name", "integrator implementation", l_ecf_client_supplier.description)
			end
		end

	sample_ecf_tests
			-- `sample_ecf_tests'
		local
			l_callbacks: IG_ECF_XML_CALLBACKS
			l_parser: XML_LITE_PARSER
			l_count: INTEGER
		do
			create l_callbacks.make
			l_parser := (create {XML_LITE_PARSER_FACTORY}).new_parser
			l_parser.set_callbacks (l_callbacks)
			l_parser.parse_from_string (sample_ecf)

				-- Testing ...

				-- System Name, UUID
			if attached l_callbacks.last_system_name as al_item then
				assert_strings_equal ("system_name", "integrator", al_item)
			end
			if attached l_callbacks.last_uuid as al_item then
				assert_strings_equal ("system_uuid", "4044DD19-B545-FAE6-1541-00005FD08DC5", al_item)
			end

				-- Descriptions
			assert_integers_equal ("4_descriptions", 4, l_callbacks.descriptions.count)
			check l_callbacks.descriptions.count > 0 and then attached l_callbacks.descriptions [1] as al_item then
				assert_strings_equal ("descritption_name", "integrator implementation", al_item)
			end

				-- Targets
			assert_integers_equal ("2_targets", 2, l_callbacks.targets.count)
			assert_32 ("all_equal", across (1 |..| 2) as ic all (<<"integrator", "test">>) [ic.item].same_string (l_callbacks.targets [ic.item]) end)
			assert_strings_equal ("last_target", "test", l_callbacks.targets [l_callbacks.targets.count])

				-- Libraries (ISE, GITHUB, local)
			assert_integers_equal ("library_count", 15, l_callbacks.suppliers.count)
			across l_callbacks.suppliers as ic_libs from l_count := 0 loop
				l_count := l_count + ic_libs.item.is_github.to_integer
			end
			assert_integers_equal ("has_5_githubs", 5, l_count)
			across l_callbacks.suppliers as ic_libs from l_count := 0 loop
				l_count := l_count + ic_libs.item.is_ise.to_integer
			end
			assert_integers_equal ("has_10_githubs", 10, l_count)
		end

	sample_pub_sub_ecf_tests
			-- `sample_class_attribute_ecf_tests'
		local
			l_callbacks: IG_ECF_XML_CALLBACKS
			l_parser: XML_LITE_PARSER
			l_count: INTEGER
		do
			create l_callbacks.make
			l_parser := (create {XML_LITE_PARSER_FACTORY}).new_parser
			l_parser.set_callbacks (l_callbacks)
			l_parser.parse_from_string (sample_pub_sub_ecf)

				-- Testing ...

				-- System Name, UUID
			if attached l_callbacks.last_system_name as al_item then
				assert_strings_equal ("system_name", "pub_sub", al_item)
			end
			if attached l_callbacks.last_uuid as al_item then
				assert_strings_equal ("system_uuid", "08C0424D-728F-4F6F-8C30-5BE714CC98FE", al_item)
			end

				-- Descriptions
			assert_integers_equal ("descriptions", 4, l_callbacks.descriptions.count)
			check l_callbacks.descriptions.count > 0 and then attached l_callbacks.descriptions [1] as al_item then
				assert_strings_equal ("descritption_name", "Publisher-Subscriber Library", al_item)
			end

				-- Targets
			assert_integers_equal ("2_targets", 2, l_callbacks.targets.count)
			across l_callbacks.targets as ic loop print (ic.item.out + "%N") end
			assert_32 ("all_equal", across (1 |..| 2) as ic all (<<"pub_sub", "test">>) [ic.item].same_string (l_callbacks.targets [ic.item]) end)
			assert_strings_equal ("last_target", "test", l_callbacks.targets [l_callbacks.targets.count])

				-- Libraries (ISE, GITHUB, local)
			assert_integers_equal ("library_count", 5, l_callbacks.suppliers.count)

				-- Check the github counts ...
			across l_callbacks.suppliers as ic_libs from l_count := 0 loop
				l_count := l_count + ic_libs.item.is_github.to_integer
			end
			assert_integers_equal ("has_githubs", 1, l_count)

				-- Check the ISE counts ...
			across l_callbacks.suppliers as ic_libs from l_count := 0 loop
				l_count := l_count + ic_libs.item.is_ise.to_integer
			end
			assert_integers_equal ("has_ises", 4, l_count)

				-- Check the local counts ...
			across l_callbacks.suppliers as ic_libs from l_count := 0 loop
				l_count := l_count + ic_libs.item.is_local.to_integer
			end
			assert_integers_equal ("has_locals", 0, l_count)

				-- Ensure there is nothing listed as local, but also github or ise ...
			across l_callbacks.suppliers as ic_libs from l_count := 0 loop
				l_count := l_count + (ic_libs.item.is_local and not (ic_libs.item.is_github or ic_libs.item.is_ise)).to_integer
			end
			assert_integers_equal ("has_0_conflicting", 0, l_count)
		end

feature {NONE} -- Implementation

	sample_pub_sub_ecf: STRING = "[
<?xml version="1.0" encoding="ISO-8859-1"?>
<system xmlns="http://www.eiffel.com/developers/xml/configuration-1-15-0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.eiffel.com/developers/xml/configuration-1-15-0 http://www.eiffel.com/developers/xml/configuration-1-15-0.xsd" name="pub_sub" uuid="08C0424D-728F-4F6F-8C30-5BE714CC98FE" library_target="pub_sub">
	<description>Publisher-Subscriber Library</description>
	<target name="pub_sub">
		<root class="ANY" feature="default_create"/>
		<option warning="true" is_obsolete_routine_type="true" void_safety="transitional" syntax="provisional">
			<assertions precondition="true" postcondition="true" check="true" invariant="true" loop="true" supplier_precondition="true"/>
		</option>
		<setting name="console_application" value="true"/>
		<library name="base" location="$ISE_LIBRARY\library\base\base-safe.ecf"/>
		<library name="randomizer" location="..\randomizer\randomizer.ecf"/>
		<library name="uuid" location="$ISE_LIBRARY\library\uuid\uuid-safe.ecf"/>
		<cluster name="pub_sub" location=".\" recursive="true">
			<file_rule>
				<exclude>/EIFGENs$</exclude>
				<exclude>tests</exclude>
				<exclude>/CVS$</exclude>
				<exclude>/.svn$</exclude>
				<exclude>/.git$</exclude>
			</file_rule>
		</cluster>
	</target>
	<target name="test" extends="pub_sub">
		<description>Pub sub test</description>
		<root class="MOCK_APPLICATION" feature="make"/>
		<file_rule>
			<exclude>/.git$</exclude>
			<exclude>/EIFGENs$</exclude>
			<exclude>/CVS$</exclude>
			<exclude>/.svn$</exclude>
			<include>tests</include>
		</file_rule>
		<option profile="true">
		</option>
		<setting name="console_application" value="false"/>
		<library name="testing" location="$ISE_LIBRARY\library\testing\testing-safe.ecf"/>
		<library name="vision2" location="$ISE_LIBRARY\library\vision2\vision2-safe.ecf"/>
		<cluster name="tests" location=".\tests\" recursive="true"/>
	</target>
</system>
]"

	sample_ecf: STRING = "[
<?xml version="1.0" encoding="ISO-8859-1"?>
<system xmlns="http://www.eiffel.com/developers/xml/configuration-1-15-0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.eiffel.com/developers/xml/configuration-1-15-0 http://www.eiffel.com/developers/xml/configuration-1-15-0.xsd" name="integrator" uuid="4044DD19-B545-FAE6-1541-00005FD08DC5" readonly="false">
	<description>integrator implementation</description>
	<target name="integrator">
		<root class="IG_SCOTTY_APPLICATION" feature="make"/>
		<option warning="true" void_safety="transitional" syntax="provisional">
			<assertions precondition="true" postcondition="true" check="true" invariant="true" loop="true" supplier_precondition="true"/>
		</option>
		<setting name="console_application" value="true"/>
		<library name="base" location="$ISE_LIBRARY\library\base\base-safe.ecf"/>
		<library name="curl" location="$ISE_LIBRARY\library\curl\curl-safe.ecf"/>
		<library name="docking" location="$ISE_LIBRARY\library\docking\docking-safe.ecf"/>
		<library name="logging_extension" location="..\logging_extension\logging_extension.ecf"/>
		<library name="net" location="$ISE_LIBRARY\library\net\net-safe.ecf"/>
		<library name="process" location="$ISE_LIBRARY\library\process\process-safe.ecf"/>
		<library name="pub_sub" location="..\pub_sub\pub_sub.ecf"/>
		<library name="randomizer" location="..\randomizer\randomizer.ecf"/>
		<library name="state_machine" location="..\state_machine\state_machine.ecf"/>
		<library name="time" location="$ISE_LIBRARY\library\time\time-safe.ecf"/>
		<library name="uuid" location="$ISE_LIBRARY\library\uuid\uuid-safe.ecf"/>
		<library name="validation" location="..\validation\validation.ecf"/>
		<library name="vision2" location="$ISE_LIBRARY\library\vision2\vision2-safe.ecf"/>
		<library name="xml_parser" location="$ISE_LIBRARY\library\text\parser\xml\parser\xml_parser-safe.ecf"/>
		<cluster name="integrator" location=".\" recursive="true">
			<file_rule>
				<exclude>/.git$</exclude>
				<exclude>/.svn$</exclude>
				<exclude>/CVS$</exclude>
				<exclude>/EIFGENs$</exclude>
				<exclude>tests</exclude>
			</file_rule>
		</cluster>
	</target>
	<target name="test" extends="integrator">
		<description>integrator Tests</description>
		<root class="ANY" feature="default_create"/>
		<file_rule>
			<exclude>/.git$</exclude>
			<exclude>/.svn$</exclude>
			<exclude>/CVS$</exclude>
			<exclude>/EIFGENs$</exclude>
			<include>tests</include>
		</file_rule>
		<option profile="false">
		</option>
		<setting name="console_application" value="false"/>
		<library name="testing" location="$ISE_LIBRARY\library\testing\testing-safe.ecf"/>
		<cluster name="tests" location=".\tests\" recursive="true"/>
	</target>
</system>
]"

end


