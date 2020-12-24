LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY LCD IS 

PORT(
	clk 			   : IN STD_LOGIC; -- LCD Clock Input
	
	-- LCD Control Signals
	lcd_en             : INOUT STD_LOGIC; -- Enable Signal
	lcd_rs             : OUT STD_LOGIC; -- Register Select Signal
	lcd_rw             : OUT STD_LOGIC; -- Read/Write Select Signal
	lcd_on             : OUT STD_LOGIC; -- LCD Power Signal
	lcd_bl             : OUT STD_LOGIC; -- LCD Back Light Signal
	
	-- Data Bus Signals
	data_bus		   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- LCD Data Bus(8-bit)
	user_data          : IN STD_LOGIC_VECTOR(7 DOWNTO 0)   -- LCD Input Data
	);
	
END LCD;

ARCHITECTURE LCD_INTIALIZATION OF LCD IS  
	
-- State Space Machine --
TYPE CONTROL IS (pwr_up, init, done);
SIGNAL state  : CONTROL; 
CONSTANT freq : INTEGER := 50; -- System frequency is 50 MHz

BEGIN 
	
	lcd_on <= '1'; -- LCD Power ON 
	lcd_bl <= '1'; -- LCD Back Light ON
	
	PROCESS(clk)
	
	VARIABLE clk_count : INTEGER := 0; -- Clock Counter
	
	BEGIN
		IF (RISING_EDGE(clk)) THEN 
			
			CASE state IS 
				WHEN pwr_up => 
					IF(clk_count < 50000*freq) THEN -- Wait 50 ms
						clk_count := clk_count + 1; -- Increamenting the Clock Counter
						state <= pwr_up; -- Loops to the same state
						
					ELSE 
						clk_count := 0; -- Resets the Clock Counter to 0  
						lcd_rs <= '0'; -- Register Select is Set to LOW 
						lcd_rw <= '0'; -- Read/Write is Set to LOW
						lcd_en <= '0'; -- Sets the Enable to LOW 
						data_bus <= "00000000"; -- Initializaing all the data lines to 0
						state <= init; -- Changes to Initialization State 
					END IF;
						
				WHEN init => 
					clk_count := clk_count + 1;
					
					IF(clk_count < (10*freq)) THEN -- Wait 10 us
						data_bus <= "00000001"; -- Clear Display
						lcd_en <= '1'; -- Sets the Enable High
						state <= init; -- Loops to Initialization State
						
					ELSIF(clk_count < (2010*freq)) THEN -- Wait 2 ms
						lcd_en <= '0'; -- Sets the Enable Low
						data_bus <= "00000000"; -- Clears the data bus 
						state <= init; -- Loops to Initialization State
						
					ELSIF(clk_count < (2020*freq)) THEN -- Wait 10 us
						data_bus <= "00111100"; -- Function Set, 2-line mode, 5x8 pixels
						lcd_en <= '1'; -- Sets the Enable High
						state <= init; -- Loops to Initialization State
						
					ELSIF(clk_count < (2070*freq)) THEN -- Wait 50 us
						lcd_en <= '0'; -- Sets the Enable Low
						data_bus <= "00000000"; -- Clears the data bus 
						state <= init; -- Loops to Initialization State
						
					ELSIF(clk_count < (2080*freq)) THEN -- Wait 10 us
						data_bus <= "00001100"; -- Display ON, Cursor Off, Cursor Blinking Off
						lcd_en <= '1'; -- Sets the Enable High
						state <= init; -- Loops to Initialization State
						
					ELSIF(clk_count < (2130*freq)) THEN -- Wait 50 us
						lcd_en <= '0'; -- Sets the Enable Low 
						data_bus <= "00000000"; -- Clears the data bus 
						state <= init; -- Loops to Initialization State
	
					ELSIF(clk_count < (2140*freq)) THEN -- Wait 10 us
						data_bus <= "00000110"; -- Clear Display
						lcd_en <= '1'; -- Sets the Enable High
						state <= init; -- Loops to Initialization State
						
					ELSIF(clk_count < (2190*freq)) THEN -- Wait 2 ms
						lcd_en <= '0'; -- Sets the Enable Low 
						data_bus <= "00000000"; -- Clears the data bus
						state <= init; -- Loops to Initialization State
						
					ELSE
						clk_count := 0; -- Resets the Clock Counter to Zero
						state <= done;
						
					END IF;
											
				WHEN done =>
				
					clk_count := clk_count + 1;
					IF(clk_count < (10*freq)) THEN -- Wait 10 us
						lcd_rs <= '0'; -- Sets rs Low
						lcd_rw <= '0'; -- Sets rw Low
						data_bus <= "00000010"; -- Return home
						lcd_en <= '1'; -- Sets the Enable High
						state <= done; 
						
					ELSIF(clk_count < (2010*freq)) THEN -- Wait 2 ms
						lcd_en <= '0'; -- Sets the Enable Low
						data_bus <= "00000000"; -- Clears the data bus
						state <= done; 
						
					ELSIF(clk_count < (2020*freq)) THEN -- Wait 10 us
						lcd_rs <= '1'; -- rs is set HIGH 
						lcd_rw <= '0'; -- rw is set LOW
						data_bus <= user_data; -- User data is sent to the LCD
						lcd_en <= '1'; -- Sets the Enable High
						state <= done;
						
					ELSIF(clk_count < (2070*freq)) THEN -- Wait 50 us
						lcd_en <= '0'; -- Sets the Enable Low 
						data_bus <= "00000000"; -- clears the data bus
						state <= done;
						
					ELSE
					clk_count := 0; -- Clear the clk_count
					state <= done;
					
					END IF;
					
			END CASE;
		END IF;		
	END PROCESS;
END LCD_INTIALIZATION;