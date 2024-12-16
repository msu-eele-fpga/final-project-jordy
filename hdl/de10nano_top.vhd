-- SPDX-License-Identifier: MIT
-- Copyright (c) 2024 Ross K. Snider, Trevor Vannoy.  All rights reserved.
----------------------------------------------------------------------------
-- Description:  Top level VHDL file for the DE10-Nano
----------------------------------------------------------------------------
-- Author:       Ross K. Snider, Trevor Vannoy
-- Company:      Montana State University
-- Create Date:  September 1, 2017
-- Revision:     1.0
-- License: MIT  (opensource.org/licenses/MIT)
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_primitives_components.all;

-----------------------------------------------------------
-- Signal Names are defined in the DE10-Nano User Manual
-- http://de10-nano.terasic.com
-----------------------------------------------------------
entity de10nano_top is
  port (
    ----------------------------------------
    --  Clock inputs
    --  See DE10 Nano User Manual page 23
    ----------------------------------------
    fpga_clk1_50 : in    std_ulogic;
    fpga_clk2_50 : in    std_ulogic;
    fpga_clk3_50 : in    std_ulogic;

    ----------------------------------------
    --  HDMI
    --  See DE10 Nano User Manual page 34
    ----------------------------------------
    hdmi_i2c_scl : inout std_logic;
    hdmi_i2c_sda : inout std_logic;
    hdmi_i2s     : inout std_logic;
    hdmi_lrclk   : inout std_logic;
    hdmi_mclk    : inout std_logic;
    hdmi_sclk    : inout std_logic;
    hdmi_tx_clk  : out   std_logic;
    hdmi_tx_d    : out   std_logic_vector(23 downto 0);
    hdmi_tx_de   : out   std_logic;
    hdmi_tx_hs   : out   std_logic;
    hdmi_tx_int  : in    std_logic;
    hdmi_tx_vs   : out   std_logic;

    ----------------------------------------
    --  DDR3
    --  See DE10 Nano User Manual page 39
    ----------------------------------------
    hps_ddr3_addr    : out   std_logic_vector(14 downto 0);
    hps_ddr3_ba      : out   std_logic_vector(2 downto 0);
    hps_ddr3_cas_n   : out   std_logic;
    hps_ddr3_ck_n    : out   std_logic;
    hps_ddr3_ck_p    : out   std_logic;
    hps_ddr3_cke     : out   std_logic;
    hps_ddr3_cs_n    : out   std_logic;
    hps_ddr3_dm      : out   std_logic_vector(3 downto 0);
    hps_ddr3_dq      : inout std_logic_vector(31 downto 0);
    hps_ddr3_dqs_n   : inout std_logic_vector(3 downto 0);
    hps_ddr3_dqs_p   : inout std_logic_vector(3 downto 0);
    hps_ddr3_odt     : out   std_logic;
    hps_ddr3_ras_n   : out   std_logic;
    hps_ddr3_reset_n : out   std_logic;
    hps_ddr3_rzq     : in    std_logic;
    hps_ddr3_we_n    : out   std_logic;

    ----------------------------------------
    --  Ethernet
    --  See DE10 Nano User Manual page 36
    ----------------------------------------
    hps_enet_gtx_clk : out   std_logic;
    hps_enet_int_n   : inout std_logic;
    hps_enet_mdc     : out   std_logic;
    hps_enet_mdio    : inout std_logic;
    hps_enet_rx_clk  : in    std_logic;
    hps_enet_rx_data : in    std_logic_vector(3 downto 0);
    hps_enet_rx_dv   : in    std_logic;
    hps_enet_tx_data : out   std_logic_vector(3 downto 0);
    hps_enet_tx_en   : out   std_logic;

    ----------------------------------------
    --  HPS i2c
    --  See DE10 Nano User Manual page 34
    ----------------------------------------
    hps_i2c1_sclk : inout std_logic;
    hps_i2c1_sdat : inout std_logic;

    ----------------------------------------
    --  HPS user I/O
    --  See DE10 Nano User Manual page 36
    ----------------------------------------
    hps_key : inout std_logic;
    hps_led : inout std_logic;

    ----------------------------------------
    --  HPS SD card
    --  See DE10 Nano User Manual page 42
    ----------------------------------------
    hps_sd_clk  : out   std_logic;
    hps_sd_cmd  : inout std_logic;
    hps_sd_data : inout std_logic_vector(3 downto 0);

    ----------------------------------------
    --  HPS UART
    --  See DE10 Nano User Manual page 38
    ----------------------------------------
    hps_uart_rx    : in    std_logic;
    hps_uart_tx    : out   std_logic;
    hps_conv_usb_n : inout std_logic;

    ----------------------------------------
    --  HPS USB OTG
    --  See DE10 Nano User Manual page 43
    ----------------------------------------
    hps_usb_clkout : in    std_logic;
    hps_usb_data   : inout std_logic_vector(7 downto 0);
    hps_usb_dir    : in    std_logic;
    hps_usb_nxt    : in    std_logic;
    hps_usb_stp    : out   std_logic;

    ----------------------------------------
    --  HPS accelerometer
    --  See DE10 Nano User Manual page 44
    ----------------------------------------
    hps_gsensor_int : inout std_logic;
    hps_i2c0_sclk   : inout std_logic;
    hps_i2c0_sdat   : inout std_logic;

    ----------------------------------------
    --  LTC connector
    --  See DE10 Nano User Manual page 45
    ----------------------------------------
    hps_ltc_gpio  : inout std_logic;
    hps_spim_clk  : out   std_logic;
    hps_spim_miso : in    std_logic;
    hps_spim_mosi : out   std_logic;
    hps_spim_ss   : inout std_logic;

    ----------------------------------------
    --  Push button inputs (KEY[0] and KEY[1])
    --  See DE10 Nano User Manual page 24
    --  The KEY push button inputs produce a '0'
    --  when pressed (asserted)
    --  and produce a '1' in the rest (non-pushed) state
    ----------------------------------------
    push_button_n : in    std_ulogic_vector(1 downto 0);

    ----------------------------------------
    --  Slide switch inputs (SW)
    --  See DE10 Nano User Manual page 25
    --  The slide switches produce a '0' when
    --  in the down position
    --  (towards the edge of the board)
    ----------------------------------------
    sw : in    std_logic_vector(3 downto 0);

    ----------------------------------------
    --  LED outputs
    --  See DE10 Nano User Manual page 26
    --  Setting LED to 1 will turn it on
    ----------------------------------------
    led : out   std_logic_vector(7 downto 0);

    ----------------------------------------
    --  GPIO expansion headers (40-pin)
    --  See DE10 Nano User Manual page 27
    --  Pin 11 = 5V supply (1A max)
    --  Pin 29 = 3.3 supply (1.5A max)
    --  Pins 12, 30 = GND
    ----------------------------------------
    gpio_0 : inout std_logic_vector(35 downto 0);
    gpio_1 : inout std_logic_vector(35 downto 0);

    ----------------------------------------
    --  Arudino headers
    --  See DE10 Nano User Manual page 30
    ----------------------------------------
    arduino_io      : inout std_ulogic_vector(15 downto 0);
    arduino_reset_n : inout std_ulogic;

    ----------------------------------------
    --  ADC header
    --  See DE10 Nano User Manual page 32
    ----------------------------------------
    adc_convst : out   std_logic;
    adc_sck    : out   std_logic;
    adc_sdi    : out   std_logic;
    adc_sdo    : in    std_logic
  );
end entity de10nano_top;

architecture de10nano_arch of de10nano_top is

	component soc_system is
		port (
		clk_clk                         : in    std_logic                     := 'X';             -- clk
			hps_io_hps_io_emac1_inst_TX_CLK : out   std_logic;                                        -- hps_io_emac1_inst_TX_CLK
			hps_io_hps_io_emac1_inst_TXD0   : out   std_logic;                                        -- hps_io_emac1_inst_TXD0
			hps_io_hps_io_emac1_inst_TXD1   : out   std_logic;                                        -- hps_io_emac1_inst_TXD1
			hps_io_hps_io_emac1_inst_TXD2   : out   std_logic;                                        -- hps_io_emac1_inst_TXD2
			hps_io_hps_io_emac1_inst_TXD3   : out   std_logic;                                        -- hps_io_emac1_inst_TXD3
			hps_io_hps_io_emac1_inst_RXD0   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD0
			hps_io_hps_io_emac1_inst_MDIO   : inout std_logic                     := 'X';             -- hps_io_emac1_inst_MDIO
			hps_io_hps_io_emac1_inst_MDC    : out   std_logic;                                        -- hps_io_emac1_inst_MDC
			hps_io_hps_io_emac1_inst_RX_CTL : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CTL
			hps_io_hps_io_emac1_inst_TX_CTL : out   std_logic;                                        -- hps_io_emac1_inst_TX_CTL
			hps_io_hps_io_emac1_inst_RX_CLK : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CLK
			hps_io_hps_io_emac1_inst_RXD1   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD1
			hps_io_hps_io_emac1_inst_RXD2   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD2
			hps_io_hps_io_emac1_inst_RXD3   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD3
			hps_io_hps_io_sdio_inst_CMD     : inout std_logic                     := 'X';             -- hps_io_sdio_inst_CMD
			hps_io_hps_io_sdio_inst_D0      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D0
			hps_io_hps_io_sdio_inst_D1      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D1
			hps_io_hps_io_sdio_inst_CLK     : out   std_logic;                                        -- hps_io_sdio_inst_CLK
			hps_io_hps_io_sdio_inst_D2      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D2
			hps_io_hps_io_sdio_inst_D3      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D3
			hps_io_hps_io_usb1_inst_D0      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D0
			hps_io_hps_io_usb1_inst_D1      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D1
			hps_io_hps_io_usb1_inst_D2      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D2
			hps_io_hps_io_usb1_inst_D3      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D3
			hps_io_hps_io_usb1_inst_D4      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D4
			hps_io_hps_io_usb1_inst_D5      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D5
			hps_io_hps_io_usb1_inst_D6      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D6
			hps_io_hps_io_usb1_inst_D7      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D7
			hps_io_hps_io_usb1_inst_CLK     : in    std_logic                     := 'X';             -- hps_io_usb1_inst_CLK
			hps_io_hps_io_usb1_inst_STP     : out   std_logic;                                        -- hps_io_usb1_inst_STP
			hps_io_hps_io_usb1_inst_DIR     : in    std_logic                     := 'X';             -- hps_io_usb1_inst_DIR
			hps_io_hps_io_usb1_inst_NXT     : in    std_logic                     := 'X';             -- hps_io_usb1_inst_NXT
			hps_io_hps_io_spim1_inst_CLK    : out   std_logic;                                        -- hps_io_spim1_inst_CLK
			hps_io_hps_io_spim1_inst_MOSI   : out   std_logic;                                        -- hps_io_spim1_inst_MOSI
			hps_io_hps_io_spim1_inst_MISO   : in    std_logic                     := 'X';             -- hps_io_spim1_inst_MISO
			hps_io_hps_io_spim1_inst_SS0    : out   std_logic;                                        -- hps_io_spim1_inst_SS0
			hps_io_hps_io_uart0_inst_RX     : in    std_logic                     := 'X';             -- hps_io_uart0_inst_RX
			hps_io_hps_io_uart0_inst_TX     : out   std_logic;                                        -- hps_io_uart0_inst_TX
			hps_io_hps_io_i2c0_inst_SDA     : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SDA
			hps_io_hps_io_i2c0_inst_SCL     : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SCL
			hps_io_hps_io_i2c1_inst_SDA     : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SDA
			hps_io_hps_io_i2c1_inst_SCL     : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SCL
			hps_io_hps_io_gpio_inst_GPIO09  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO09
			hps_io_hps_io_gpio_inst_GPIO35  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO35
			hps_io_hps_io_gpio_inst_GPIO40  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO40
			hps_io_hps_io_gpio_inst_GPIO53  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO53
			hps_io_hps_io_gpio_inst_GPIO54  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO54
			hps_io_hps_io_gpio_inst_GPIO61  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO61
			memory_mem_a                    : out   std_logic_vector(14 downto 0);                    -- mem_a
			memory_mem_ba                   : out   std_logic_vector(2 downto 0);                     -- mem_ba
			memory_mem_ck                   : out   std_logic;                                        -- mem_ck
			memory_mem_ck_n                 : out   std_logic;                                        -- mem_ck_n
			memory_mem_cke                  : out   std_logic;                                        -- mem_cke
			memory_mem_cs_n                 : out   std_logic;                                        -- mem_cs_n
			memory_mem_ras_n                : out   std_logic;                                        -- mem_ras_n
			memory_mem_cas_n                : out   std_logic;                                        -- mem_cas_n
			memory_mem_we_n                 : out   std_logic;                                        -- mem_we_n
			memory_mem_reset_n              : out   std_logic;                                        -- mem_reset_n
			memory_mem_dq                   : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
			memory_mem_dqs                  : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
			memory_mem_dqs_n                : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
			memory_mem_odt                  : out   std_logic;                                        -- mem_odt
			memory_mem_dm                   : out   std_logic_vector(3 downto 0);                     -- mem_dm
			memory_oct_rzqin                : in    std_logic                     := 'X';             -- oct_rzqin
			output_sclk                     : out   std_logic;                                        -- sclk
			output_cs_n                     : out   std_logic;                                        -- cs_n
			output_dout                     : in    std_logic                     := 'X';             -- dout
			output_din                      : out   std_logic;                                        -- din
			reset_reset_n                   : in    std_logic                     := 'X';             -- reset_n
			rgb_led_switches                : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- switches
			rgb_led_readdata                : out   std_logic_vector(7 downto 0);                     -- readdata
			rgb_led_red_output              : out   std_logic;                                        -- red_output
			rgb_led_green_output            : out   std_logic;                                        -- green_output
			rgb_led_blue_output             : out   std_logic                                         -- blue_output
		);
	end component soc_system;


signal push_button 		: std_ulogic_vector(1 downto 0);

begin
	push_button(0) <= not push_button_n(0); -- Invert push buttons to logic high
	push_button(1) <= not push_button_n(1);
	u0 : component soc_system
	port map (
	-- ethernet
		hps_io_hps_io_emac1_inst_tx_clk => hps_enet_gtx_clk,
		hps_io_hps_io_emac1_inst_txd0   => hps_enet_tx_data(0),
		hps_io_hps_io_emac1_inst_txd1   => hps_enet_tx_data(1),
		hps_io_hps_io_emac1_inst_txd2   => hps_enet_tx_data(2),
		hps_io_hps_io_emac1_inst_txd3   => hps_enet_tx_data(3),
		hps_io_hps_io_emac1_inst_mdio   => hps_enet_mdio,
		hps_io_hps_io_emac1_inst_mdc    => hps_enet_mdc,
		hps_io_hps_io_emac1_inst_rx_ctl => hps_enet_rx_dv,
		hps_io_hps_io_emac1_inst_tx_ctl => hps_enet_tx_en,
		hps_io_hps_io_emac1_inst_rx_clk => hps_enet_rx_clk,
		hps_io_hps_io_emac1_inst_rxd0   => hps_enet_rx_data(0),
		hps_io_hps_io_emac1_inst_rxd1   => hps_enet_rx_data(1),
		hps_io_hps_io_emac1_inst_rxd2   => hps_enet_rx_data(2),
		hps_io_hps_io_emac1_inst_rxd3   => hps_enet_rx_data(3),
		hps_io_hps_io_gpio_inst_gpio35  => hps_enet_int_n,

		-- sd card
		hps_io_hps_io_sdio_inst_cmd => hps_sd_cmd,
		hps_io_hps_io_sdio_inst_clk => hps_sd_clk,
		hps_io_hps_io_sdio_inst_d0  => hps_sd_data(0),
		hps_io_hps_io_sdio_inst_d1  => hps_sd_data(1),
		hps_io_hps_io_sdio_inst_d2  => hps_sd_data(2),
		hps_io_hps_io_sdio_inst_d3  => hps_sd_data(3),

		-- usb
		hps_io_hps_io_usb1_inst_d0  => hps_usb_data(0),
		hps_io_hps_io_usb1_inst_d1  => hps_usb_data(1),
		hps_io_hps_io_usb1_inst_d2  => hps_usb_data(2),
		hps_io_hps_io_usb1_inst_d3  => hps_usb_data(3),
		hps_io_hps_io_usb1_inst_d4  => hps_usb_data(4),
		hps_io_hps_io_usb1_inst_d5  => hps_usb_data(5),
		hps_io_hps_io_usb1_inst_d6  => hps_usb_data(6),
		hps_io_hps_io_usb1_inst_d7  => hps_usb_data(7),
		hps_io_hps_io_usb1_inst_clk => hps_usb_clkout,
		hps_io_hps_io_usb1_inst_stp => hps_usb_stp,
		hps_io_hps_io_usb1_inst_dir => hps_usb_dir,
		hps_io_hps_io_usb1_inst_nxt => hps_usb_nxt,

		-- UART
		hps_io_hps_io_uart0_inst_rx    => hps_uart_rx,
		hps_io_hps_io_uart0_inst_tx    => hps_uart_tx,
		hps_io_hps_io_gpio_inst_gpio09 => hps_conv_usb_n,

		-- LTC connector
		hps_io_hps_io_gpio_inst_gpio40 => hps_ltc_gpio,
		hps_io_hps_io_spim1_inst_clk   => hps_spim_clk,
		hps_io_hps_io_spim1_inst_mosi  => hps_spim_mosi,
		hps_io_hps_io_spim1_inst_miso  => hps_spim_miso,
		hps_io_hps_io_spim1_inst_ss0   => hps_spim_ss,
		hps_io_hps_io_i2c1_inst_sda    => hps_i2c1_sdat,
		hps_io_hps_io_i2c1_inst_scl    => hps_i2c1_sclk,

		-- I2C for accelerometer
		hps_io_hps_io_gpio_inst_gpio61 => hps_gsensor_int,
		hps_io_hps_io_i2c0_inst_sda    => hps_i2c0_sdat,
		hps_io_hps_io_i2c0_inst_scl    => hps_i2c0_sclk,

		-- HPS user I/O
		hps_io_hps_io_gpio_inst_gpio53 => hps_led,
		hps_io_hps_io_gpio_inst_gpio54 => hps_key,

		-- DDR3
		memory_mem_a       => hps_ddr3_addr,
		memory_mem_ba      => hps_ddr3_ba,
		memory_mem_ck      => hps_ddr3_ck_p,
		memory_mem_ck_n    => hps_ddr3_ck_n,
		memory_mem_cke     => hps_ddr3_cke,
		memory_mem_cs_n    => hps_ddr3_cs_n,
		memory_mem_ras_n   => hps_ddr3_ras_n,
		memory_mem_cas_n   => hps_ddr3_cas_n,
		memory_mem_we_n    => hps_ddr3_we_n,
		memory_mem_reset_n => hps_ddr3_reset_n,
		memory_mem_dq      => hps_ddr3_dq,
		memory_mem_dqs     => hps_ddr3_dqs_p,
		memory_mem_dqs_n   => hps_ddr3_dqs_n,
		memory_mem_odt     => hps_ddr3_odt,
		memory_mem_dm      => hps_ddr3_dm,
		memory_oct_rzqin   => hps_ddr3_rzq,
		output_sclk                     => adc_sck,                     --  output.sclk
		output_cs_n                     => adc_convst,                     --        .cs_n
      output_dout                     => adc_sdo,                     --        .dout
      output_din                      => adc_sdi,                      --        .din
      rgb_led_switches                => sw,                -- rgb_led.switches
      rgb_led_readdata                => led,                --        .readdata
      rgb_led_red_output              => gpio_0(0),              --        .red_output
      rgb_led_green_output            => gpio_0(2),            --        .green_output
      rgb_led_blue_output             => gpio_0(4),              --        .blue_output

		clk_clk       => fpga_clk1_50,
		reset_reset_n => push_button(0)-- hook up to your reset signal; note that reset_reset_n is *active-low*
	);


  


end architecture de10nano_arch;
