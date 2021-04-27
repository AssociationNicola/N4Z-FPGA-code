////////////////////////////////////////////////////////////////////////////////
// 
//  Copyright (c) 2018, Darryl Ring.
// 
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along with
//  this program; if not, see <https://www.gnu.org/licenses/>.
//
//  Additional permission under GNU GPL version 3 section 7:
//  If you modify this program, or any covered work, by linking or combining it
//  with independent modules provided by the FPGA vendor only (this permission
//  does not extend to any 3rd party modules, "soft cores" or macros) under
//  different license terms solely for the purpose of generating binary
//  "bitstream" files and/or simulating the code, the copyright holders of this
//  program give you the right to distribute the covered work without those
//  independent modules as long as the source code for them is available from
//  the FPGA vendor free of charge, and there is no dependence on any encrypted
//  modules for simulating of the combined code. This permission applies to you
//  if the distributed code contains all the components and scripts required to
//  completely simulate it with at least one of the Free Software programs.
//
////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module ad5541
(
    input  wire        clk,
    input  wire        rstn,
    
	input  wire [15:0] data,
    input  wire        valid,
    output wire        ready,

    output wire        cs,
    output wire        din,
    output wire        ldac,
    output wire        sclk,
    
    
    output wire [2:0]       export_state,
    output wire [6:0]       count_next

);


localparam [2:0]
    STATE_IDLE       = 3'd0,
    STATE_WRITE_DAC = 3'd1,

    STATE_LOAD       = 3'd3,
    STATE_WAIT       = 3'd4;

reg [2:0] state_reg, state_next;

reg [6:0] count_reg, count_next;

reg [15:0] data_reg, data_next;

reg ready_reg, ready_next;

reg cs_reg, cs_next;
reg din_reg, din_next;
reg ldac_reg, ldac_next;
reg sclk_reg, sclk_next;

reg sclk_enable;

assign ready = ready_reg;

assign cs = cs_reg;
assign din = din_reg;
assign ldac = ldac_reg;
assign sclk = sclk_reg;
assign export_state = state_reg;
assign counter = count_next;

always @* begin
    state_next = STATE_IDLE;
    
    cs_next   = cs_reg;
    din_next  = din_reg;
    ldac_next = ldac_reg;
    sclk_next = sclk_reg;
    
    count_next = count_reg;
    data_next = data_reg;
    
    ready_next = 1'b0;
    
    case (state_reg)
        STATE_IDLE: begin
            
            if (ready & valid) begin
                data_next = data;
                ready_next = 1'b0;

                state_next = STATE_WRITE_DAC;
            end else begin
                ready_next = 1'b1;
            end
        end
        STATE_WRITE_DAC: begin
            state_next = STATE_WRITE_DAC;

            count_next = count_reg + 1;

            sclk_next = count_reg[0];

            if (count_reg == 7'h02) begin
                cs_next = 1'b0;
            end

            if (count_reg >= 7'h02 && count_reg[0] == 1'b0) begin
                {din_next, data_next} = {data_reg, 1'b0};
            end

			if (count_reg == 7'h22) begin
                cs_next = 1'b1;

                count_next = 7'b0;
                state_next = STATE_LOAD;
            end

        end

        STATE_LOAD: begin
            state_next = STATE_LOAD;
            count_next = count_reg + 1;

            if (count_reg[0] == 1'b1) begin
                ldac_next = ~ldac_reg;  
            end

            if (count_reg[2] == 1'b1) begin
                state_next = STATE_WAIT;
                count_next = 7'b0;
            end

        end
        STATE_WAIT: begin
            state_next = STATE_WAIT;
            count_next = count_reg + 1;

            if (count_reg == 7'h0e) begin
                state_next = STATE_IDLE;
                count_next = 7'b0;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (~rstn) begin
        state_reg <= STATE_IDLE;
        
        data_reg <= 16'b0;
        ready_reg <= 1'b0;
        
        count_reg <= 7'b0;
        
        cs_reg   <= 1'b1;
        din_reg  <= 1'b0;
        ldac_reg <= 1'b1;
        sclk_reg <= 1'b0;
        
    end else begin
        state_reg <= state_next;
        
        data_reg <= data_next;
        count_reg <= count_next;
        
        ready_reg <= ready_next;
        
        cs_reg <= cs_next;
        din_reg <= din_next;
        ldac_reg <= ldac_next;
        sclk_reg <= sclk_next;
    end
end


endmodule


