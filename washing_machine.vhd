----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2023 19:31:20
-- Design Name: 
-- Module Name: washing_machine - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity washing_machine_controller is
  Port (clk, lid, rst, add_rinse,coin : in std_logic);
end washing_machine_controller;

architecture Behavioral of washing_machine_controller is

type state_type is (idle,set,soak,wash,rinse,spin,dry);

signal state: state_type := idle;
signal timer: integer range 0 to 512000 := 512000;           --counts 0.001s
signal counter,T: integer range 0 to 26200 := 0;           --this will store the value of the total time for all processes in seconds
signal flag,add_rinse_mem: std_logic:='0';


begin

---------------------------------------------------------------------------------------------------------------
    
    timerr: process(clk)                        --this process measures every time a milisecond passes
    begin
        if(rising_edge(clk)) then
            if (timer>0) then
                timer<=timer-1;
            else
                timer<=512000;
                flag<=not flag;
            end if;
        end if;
    end process;
    
---------------------------------------------------------------------------------------------------------------

    overall_logic: process(flag,rst,lid)        --this process runs every time a second passses
    begin
--        if(rising_edge(flag)) then

            if(lid/='1') then 
                if (rst='1') then
                    state<=idle;
                else
                    case(state) is
                    
                        when idle=>
--                            if(coin='1') then 
--                                if(add_rinse='1') then          --storing the add rinse in memory
--                                    add_rinse_mem<='1';
----                                    T<=21833;                   --for total 131s 
--                                    T<=5;                       --for total 30ms                  
--                                    counter<=T;
--                                else
----                                    T<=26200;                   --for total 131 s
--                                    T<=6;                       --for total 30ms
--                                    counter<=T;
--                                end if;
--                                state<=soak;
--                            end if;


                            if(add_rinse='1') then
--                                T<=21833;                   --for total 131s 
                                T<=5;                       --for total 30ms                       
                                add_rinse_mem<='1';
                                if(coin='1') then
                                    state<=set;
                                       
                                end if;
                            elsif(add_rinse='0') then
--                                T<=26200;                   --for total 131 s
                                T<=6;                       --for total 30ms
                                if(coin='1') then
                                    state<=set;   
                                end if;
                            end if;
                            
                        when set=>                
                            counter<=T;
                            state<=soak;
                            
                        when soak=>
                            if(counter>0) then
                                counter<=counter-1;
                            else
                                state<=wash;
                                counter<=T;
                            end if;
                        when wash=>
                            if(counter>0) then
                                counter<=counter-1;
                            else
                                state<=rinse;
                                counter<=T;
                            end if;
                        when rinse=>
                            if(counter>0) then
                                counter<=counter-1;
                            else                               --this block will run either rinse or add_add rinse based on the given input
                                case(add_rinse_mem) is
                                    when '0'=>
                                        state<=spin;
                                    when '1'=>
                                        state<=rinse;
                                        add_rinse_mem<='0';
                                    when others =>
                                        state<=idle;
                                        add_rinse_mem<='0';
                                    end case;
                                counter<=T;
                            end if;
                        when spin=>
                            if(counter>0) then
                                counter<=counter-1;
                            else
                                state<=dry;
                                counter<=T;
                            end if;
                        when dry=>
                            if(counter>0) then
                                counter<=counter-1;
                            else
                                state<=idle;
                                counter<=T;
                            end if;  
                            
                           
                    end case;
                end if;
            end if;
--        end if;
    end process;
    
end Behavioral;