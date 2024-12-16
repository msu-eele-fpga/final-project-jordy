library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_controller is 
	generic (
		CLK_PERIOD	: time		:= 20 ns;
		W_PERIOD	: integer	:= 18;	-- Total # of bits
		W_DUTY_CYCLE	: integer	:= 11	-- Total # of bits
	);
	port (
		clk 		: in std_logic;
		rst 		: in std_logic;
		period	     	: in std_logic_vector(W_PERIOD - 1 downto 0); 		--W:18, F:12, I:6
		duty_cycle   	: in std_logic_vector(W_DUTY_CYCLE - 1 downto 0); 	--W:11, F:10, I:1
		output       	: out std_logic;
		-- CUSTOM COMPONENT SIGNALS
		duty_out	: out integer;
		period_out	: out integer
	);
end entity pwm_controller;

architecture pwm_controller_arch of pwm_controller is
	
	constant SYS_CLK_RATE		: std_logic_vector(25 downto 0) := "10111110101111000010000000";	-- 50MHz
	
	signal period_clk_cycles 	: unsigned(43 downto 0); -- period width + sys_clk width = 18 + 26 = 44
	signal duty_clk_cycles 		: unsigned(54 downto 0);
	signal cnt 			: integer := 0; 
	signal on_time 			: integer := 0;
	signal period_cnt		: integer := 0;
	
begin
	period_clk_cycles <= unsigned(period) * unsigned(SYS_CLK_RATE); 		-- period width + sys_clk width = 18 + 26 = 44
	duty_clk_cycles   <= unsigned(duty_cycle) * period_clk_cycles;
	period_cnt 	  <= to_integer(period_clk_cycles(43 downto 12)); 		-- N or W = 44 
	on_time 	  <= to_integer(duty_clk_cycles(54 downto 22));
	
	PWM : process (clk, rst) is
	begin
		
		if rst = '1' then
			cnt <= 0;
			output <= '0';
		elsif rising_edge(clk) then
			if cnt < on_time + 1 then
				cnt <= cnt + 1;
				output <= '1';
			elsif cnt < period_cnt and cnt > on_time then
				cnt <= cnt + 1;
				output <= '0';
			else
				cnt <= 0;
			end if;
		end if;
	end process PWM;

	period_out <= cnt;
	duty_out <= on_time;

end architecture pwm_controller_arch;
			
