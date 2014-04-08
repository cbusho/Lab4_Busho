Lab4_Busho
==========

## Introduction
I created a program that uses a terminal emulator to interface with switches and LEDs. This was done using two
embedded microcontrollers in my FPGA. The program was first created using an 8-bit microcontroller, Picoblaze.
The second program was created using a 32-bit microcontroller, Microblaze. The two programs have identical
functionality.

## Implementation
- I used the UART modules given to us with the Picoblaze module to communicate with the terminal. The first
step I took was hooking the input to the UART directly to the output. This made every letter appear twice
on the terminal screen. After this I took the input to the UART and put it as an input into the Picoblaze
module. I wrote a program in assembly that was then translated into a VHD file via openPICIDE. The output
of the Picoblaze module was then sent to the output of the terminal. 
 

  - This code converts two nibbles into ASCII values to output

``` VHDL
  switcher1 <= "0000" & switch(7 downto 4);
	switcher2 <= "0000" & switch(3 downto 0);
	switch1 <= std_logic_vector(unsigned(switcher1) + X"30") when switcher1 <= "00001001" else
				  std_logic_vector(unsigned(switcher1) + X"57");
	switch2 <= std_logic_vector(unsigned(switcher2) + X"30") when switcher2 <= "00001001" else
				  std_logic_vector(unsigned(switcher2) + X"57");	
```

  - This code converts an ASCII value into nibbles to be output as LEDs

``` VHDL
  num_result <= unsigned(out_port) - X"30";
	letter_result <= unsigned(out_port) - X"57";

	led_output <=  std_logic_vector(num_result) when num_result >= X"0" 
						and num_result <= X"9" else
						std_logic_vector(letter_result) when letter_result >= X"A"
						and letter_result <= X"F" else
						"00000000";

	process(clk, port_id)
	begin
		if(rising_edge(clk)) then
			if (reset = '1') then
				leds_next1 <= "0000";
			else
				if (port_id = X"06") then
					leds_next1 <= led_output(3 downto 0);
				end if;
			end if;
		end if;	
	end process;	

	process(clk, port_id)
	begin
		if(rising_edge(clk)) then
			if (reset = '1') then
				leds_next2 <= "0000";
			else
				if (port_id = X"05") then
					leds_next2 <= led_output(3 downto 0);
				end if;
			end if;
		end if;	
	end process;			


	led <= leds;
	leds <= leds_next1 & leds_next2;
```

- I also created this lab using a Microblaze module. This module had a UART module already instantiated and
working inside it. I added the LEDs and Switches as inputs and outputs in the VHD files and was able to 
write the rest of it in a C file that took the inputs and ouputs and just outputted the correct LEDs or
letters to the terminal screen.

## Test/Debug

- Learning about the signals of the UART modules took me some time. At first I had the output hooked up to
the input of the UART modules.
- I was able to test my VHD file for the Picoblaze in software by running the openPICIDE simulation.
- Sensitivity lists are still super important! It give me some trouble with the LEDs because it was not
updatting the LEDs when I was sending in new information.
- Once again, I was able to simulate my C file for the Microblaze in software. 
- The implementation of the custom peripheral gave me some trouble. I had to remember to add the switches
to the UCF file. I had to add the switches as an external port on the bus. I had to change my second slv
register to read the switches at a certain time.
  
## Conclusion
In this lab, I learned how to implement embedded microcontrollers on my FPGA. This is very helpful because
it allows you to use already optimized hardware instead of having to do all of the VHDL to realize those 
components. By using the Picoblaze and especially the Microblaze, it will now be easier to hopefully use 
the FPGA for my own projects and the final project. I can now more easily interface with other outside
peripherals and even create my own using these microcontrollers.
