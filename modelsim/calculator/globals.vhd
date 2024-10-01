-- globals.vhd
-- this package defines global types, which are used by different components

package globals is

	-- type for enumerating the keyboard events
	type key_event_type is (KEY_NUM, KEY_RESET, KEY_ENTER, KEY_ADD, KEY_SUB, KEY_DIV, KEY_MUL, KEY_OTHER);
	
	-- type for enumerating the operators
	type operator_type is (UNDEF, ADD, SUB, MUL, DIV);

end package globals;