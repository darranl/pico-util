/* Copyright 2023, Darran A Lofthouse
 *
 * This file is part of pico-util.
 *
 * pico-sha-test is free software: you can redistribute it and/or modify it under the terms 
 * of the GNU General Public License as published by the Free Software Foundation, either 
 * version 3 of the License, or (at your option) any later version.
 *
 * pico-util is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with pico-util.
 * If  not, see <https://www.gnu.org/licenses/>. 
 */

/*
 * Start the SYST count using the processor clock source.
 *
 * If the counter is already running reset it so it starts again.
 */
extern void start_syst_counter();

/*
 * Stop the SYST counter and return number of elapsed ticks.
 *
 * Return -1 if the timer was not running, -2 if a complete cycle has elapsed.
 */
extern uint32_t stop_syst_counter();