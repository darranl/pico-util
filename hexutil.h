/* Copyright 2023, Darran A Lofthouse
 *
 * This file is part of pico-util.
 *
 * pico-util is free software: you can redistribute it and/or modify it under the terms
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

#include <stdio.h>
#include "pico/stdlib.h"

extern void int_test(uint32_t * test_value);


/*
 * Convert a 8 bit unsigned integer to Hex.
 *
 * result must point to an array with room for at least 2 characters.
 */
extern void uint8_to_hex(uint8_t value, char * result);

/*
 * Convert a 32 bit unsigned integer to Hex.
 *
 * result must point to an array with room for at least 8 characters.
 */
extern void uint32_to_hex(uint32_t value, char * result);

/*
 * Convert a 32 bit unsigned integer to Hex string with temination 0.
 *
 * Omits leading 0s
 *
 * result must point to an array with room for at least 8 characters.
 */
extern void uint32_to_hex_string(uint32_t value, char * result);

/*
 * Convert up to 8  (zero terminated) chars to uint32_t.
 *
 * For longer Strings the result will be the final 8 characters.
 *
 * Max 0xFFFFFFFF
 */
extern uint32_t hex_string_to_uint32(char * hex);

/*
 * Convert exactly two hex characters to an 8 bit char.
 */
extern char hex_to_char(char * hex);