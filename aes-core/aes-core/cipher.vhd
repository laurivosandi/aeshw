library ieee;
use ieee.std_logic_1164.all;
use work.types.all;
use work.math.all;
use work.sbox.all;

entity cipher is
	port (
		din  : in  state;
		dout : out state
	);

	function sub_bytes (din : state) return state is
		variable tin : s_list;
		variable tout : s_list;
	begin
		tin := to_s_list(din);

		for i in 0 to 15 loop
			tout(i) := sbox(tin(i));
		end loop;

		return to_state(tout);
	end sub_bytes;

	function shift_rows (din : state) return state is
		variable tin : matrix;
		variable tout : matrix;
	begin
		tin := to_matrix(din);

		tout(0, 0) := tin(0, 0);
		tout(0, 1) := tin(0, 1);
		tout(0, 2) := tin(0, 2);
		tout(0, 3) := tin(0, 3);

		tout(1, 0) := tin(1, 1);
		tout(1, 1) := tin(1, 2);
		tout(1, 2) := tin(1, 3);
		tout(1, 3) := tin(1, 0);

		tout(2, 0) := tin(2, 2);
		tout(2, 1) := tin(2, 3);
		tout(2, 2) := tin(2, 0);
		tout(2, 3) := tin(2, 1);

		tout(3, 0) := tin(3, 3);
		tout(3, 1) := tin(3, 0);
		tout(3, 2) := tin(3, 1);
		tout(3, 3) := tin(3, 2);

		return to_state(tout);
	end shift_rows;

	function mix_columns (din : state) return state is
		variable tin : matrix;
		variable tout : matrix;
	begin
		tin := to_matrix(din);

		for col in 0 to 3 loop
			tout(0, col) := mul2(tin(0, col)) xor mul3(tin(1, col)) xor tin(2, col) xor tin(3, col);
			tout(1, col) := tin(0, col) xor mul2(tin(1, col)) xor mul3(tin(2, col)) xor tin(3, col);
			tout(2, col) := tin(0, col) xor tin(1, col) xor mul2(tin(2, col)) xor mul3(tin(3, col));
			tout(3, col) := mul3(tin(0, col)) xor tin(1, col) xor tin(2, col) xor mul2(tin(3, col));
		end loop;

		return to_state(tout);
	end mix_columns;

	function add_round_key (din : state; key : state) return state is
	begin
		return din xor key;
	end add_round_key;
end cipher;

architecture behavioral of cipher is
begin

	dout <= mix_columns(din);

end behavioral;

