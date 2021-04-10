`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2021 15:53:37
// Design Name: 
// Module Name: ReadModule
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ReadModule #
/*
 * AXI4 lite width adapter (read)
 */
(
    // Width of address bus in bits
    parameter ADDR_WIDTH = 32,
    // Width of input (slave) interface data bus in bits
    parameter S_DATA_WIDTH = 32,
    // Width of input (slave) interface wstrb (width of data bus in words)
    parameter S_STRB_WIDTH = (S_DATA_WIDTH/8),
    // Width of output (master) interface data bus in bits
    parameter M_DATA_WIDTH = 32,
    // Width of output (master) interface wstrb (width of data bus in words)
    parameter M_STRB_WIDTH = (M_DATA_WIDTH/8)
)
(
    input  wire                     aclk,
    input  wire                     arstn,

    /*
     * AXI lite slave interface
     */
    input  wire [ADDR_WIDTH-1:0]    s_axil_araddr,
    input  wire [2:0]               s_axil_arprot,
    input  wire                     s_axil_arvalid,
    output wire                     s_axil_arready,
    output wire [S_DATA_WIDTH-1:0]  s_axil_rdata,
    output wire                     s_axil_rvalid,
    input  wire                     s_axil_rready,

    /*
     * AXI lite master interface
     */
    output wire [ADDR_WIDTH-1:0]    m_axil_araddr,
    output wire [2:0]               m_axil_arprot,
    output m_axil_arvalid,
    input  wire                     m_axil_arready,
    input  wire [M_DATA_WIDTH-1:0]  m_axil_rdata,
    input  wire                     m_axil_rvalid,
    output wire                     m_axil_rready
);

reg [1:0] ss;
localparam S0=2'b00, READ=2'b01, DATA=2'b10;

always @(posedge aclk)
begin
    if(arstn) ss<=0;
    else 
    begin
    case(ss)
        S0: 
            if(m_axil_araddr) //araddr != NULL
            begin 
            ss<=READ;
            //m_axil_arprot? 
            m_axil_arvalid<=1; 
            m_axil_arready<=1;
            end
            else ss<=S0;
        
        READ:
            if(m_axil_rready==0 || m_axil_rvalid==0) ss<=READ; 
            else
            begin
                ss<=DATA;
                m_axil_rready<=1;
                m_axil_rvalid<=1;
                m_axil_arvalid<=0;
                m_axil_arready<=0;
                m_axil_araddr<=0;
                m_axil_arprot<=0;
            end
            
        DATA:
            begin
            ss<=S0;
            m_axil_rready<=0;
            m_axil_rvalid<=0;
            m_axil_arvalid<=0;
            m_axil_arready<=0;
            m_axil_araddr<=0;
            m_axil_arprot<=0;
            m_axil_rdatat<=0;
            end
      endcase
    end
end      
endmodule

