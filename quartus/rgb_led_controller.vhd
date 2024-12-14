library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rgb_led_controller is
	port	 (clk              	: in std_logic;
				rst              	: in std_logic;
				avs_s1_read      	: in std_logic;
				avs_s1_write     	: in std_logic;
				avs_s1_writedata 	: in std_logic_vector(31 downto 0);
				sw						: in std_logic_vector(3 downto 0);
				avs_s1_address   	: in std_logic_vector(2 downto 0);
				led		   		: out std_logic_vector(7 downto 0);
				avs_s1_readdata  	: out std_logic_vector(31 downto 0);
				red_out      		: out std_logic;
				green_out	   	: out std_logic;
				blue_out      		: out std_logic
	);
end entity rgb_led_controller;

architecture rgb_led_controller_arch of rgb_led_controller is
	
	component pwm_controller is
		generic (
			CLK_PERIOD		: time		:= 20 ns;
			W_PERIOD			: integer	:= 18;
			W_DUTY_CYCLE	: integer	:= 11	
		);
		port (
			clk 				: in std_logic;
			rst 				: in std_logic;
			period	     	: in std_logic_vector(W_PERIOD - 1 downto 0); 		--W:18, F:12, I:6
			duty_cycle   	: in std_logic_vector(W_DUTY_CYCLE - 1 downto 0); 	--W:11, F:10, I:1
			output       	: out std_logic;
			duty_out			: out integer;
			period_out		: out integer
		);
	end component pwm_controller;

	signal period       	: std_logic_vector(31 downto 0) := "00000000000000000000000011001101"; 
	signal sw_reg	    	: std_logic_vector(31 downto 0) := "00000000000000000000000000000000"; 
	signal cnt_low 		: integer := 0;
	signal cnt_mid 		: integer := 0;
	signal period_value 	: integer := 0;
	signal duty_value 	: integer := 0;

	-- RGB LED COLORS & CTRL --
	signal led_red      	: std_logic_vector(31 downto 0) := "00000000000000000010000000000000"; 
	signal led_green    	: std_logic_vector(31 downto 0) := "00000000000000000010000000000000"; 
	signal led_blue     	: std_logic_vector(31 downto 0) := "00000000000000000010000000000000"; 
	signal led_ctrl     	: std_logic_vector(31 downto 0) := "00000000000000000010000000000000"; 

	-- TEMPORARY COLOR ATTRIBUTES --
	signal green_hold 	: std_logic;
	signal red_hold 		: std_logic;
	signal blue_hold 		: std_logic;

	begin

	PWM_CTRL_RED : pwm_controller 
	port map (
		clk => clk, 
		rst => rst, 
		period=> period(17 downto 0), 
		duty_cycle => led_red(10 downto 0), 
		output => red_hold
	);
												  
	PWM_CTRL_GREEN : pwm_controller 
	port map (
		clk => clk, 
		rst => rst, 
		period=> period(17 downto 0),
 		duty_cycle => led_green(10 downto 0),
		output => green_hold
	);
												  
	PWM_CTRL_BLUE : pwm_controller 
	port map (
		clk => clk, 
		rst => rst, 
		period=> period(17 downto 0),
		duty_cycle => led_blue(10 downto 0), 
		output => blue_hold
	);

	PWM_RGB_CTRL : pwm_controller 
	port map (
		clk => clk, 
		rst => rst, 
		period=> period(17 downto 0),
		duty_cycle => led_ctrl(10 downto 0), 
		duty_out => duty_value,
		period_out => period_value
	);
	
	LED_CTRL_PROCESS : process (clk) is
	begin
	
	if rising_edge(clk) then
		
		if sw = "0000" then
			red_out <= red_hold;
			blue_out <= blue_hold;
			green_out <= green_hold;
		elsif sw /= "0000" then
			cnt_low <= period_value / 2;
			cnt_mid <= (period_value * 2) - cnt_low;
			if (duty_value < cnt_low) then
				red_out <= red_hold;
				blue_out <= '0';
				green_out <= '0';
			elsif duty_value >= cnt_low and duty_value < cnt_mid then
				red_out <= '0';
				green_out <= green_hold;
				blue_out <= '0';
			elsif duty_value >= cnt_mid then
				red_out <= '0';
				green_out <= '0';
				blue_out <= blue_hold;
			end if;
		end if;
	end if;
	end process LED_CTRL_PROCESS;

	AVALON_REGISTER_READ : process (clk) is
	begin
	
	if rising_edge(clk) and avs_s1_read = '1' then
		case avs_s1_address is
			when "000"  => avs_s1_readdata <= led_red;
			when "001"  => avs_s1_readdata <= led_green;
			when "010"  => avs_s1_readdata <= led_blue;
			when "011"  => avs_s1_readdata <= sw_reg;
		   when "100"  => avs_s1_readdata <= period;
			when "101"  => avs_s1_readdata <= led_ctrl;
			when others => avs_s1_readdata <= (others => '0');
		end case;
	end if;
	end process AVALON_REGISTER_READ;
	
	AVALON_REGISTER_WRITE : process (clk, rst) is
	begin
		if rst = '1' then
			led_red      <= "00000000000000000010000000000000";	-- Duty cycle 50% default
			led_green    <= "00000000000000000010000000000000";
			led_blue     <= "00000000000000000010000000000000";
			period       <= "00000000000000000000000011001101";	-- 50 ms period
			sw_reg       <= "00000000000000000000000000000000";
		   led_ctrl     <= "00000000000000000010000000000000";
		elsif rising_edge(clk) and avs_s1_write = '1' then
			case avs_s1_address is
				when "000"  => led_red      <= avs_s1_writedata(31 downto 0);
				when "001"  => led_green    <= avs_s1_writedata(31 downto 0);
				when "010"  => led_blue     <= avs_s1_writedata(31 downto 0);
				when "011"  => sw_reg       <= avs_s1_writedata(31 downto 0);
				when "100"  => period 	    <= avs_s1_writedata(31 downto 0);
				when "101"  => led_ctrl     <= avs_s1_writedata(31 downto 0);
				when others => null;
			end case;
		end if;
	end process AVALON_REGISTER_WRITE;

end architecture;