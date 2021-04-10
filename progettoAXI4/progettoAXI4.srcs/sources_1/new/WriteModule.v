/*
 * AXI4 lite width adapter (write)
 */
module WriteModule#
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
    input  wire [ADDR_WIDTH-1:0]    s_axil_awaddr,
    input  wire                     s_axil_awvalid,
    output wire                     s_axil_awready,
    input  wire [S_DATA_WIDTH-1:0]  s_axil_wdata,
    input  wire [S_STRB_WIDTH-1:0]  s_axil_wstrb,
    input  wire                     s_axil_wvalid,
    output wire                     s_axil_wready,
    output wire                     s_axil_bvalid,
    input  wire                     s_axil_bready,

    /*
     * AXI lite master interface
     */
    output wire [ADDR_WIDTH-1:0]    m_axil_awaddr,
    output wire                     m_axil_awvalid,
    input  wire                     m_axil_awready,
    output wire [M_DATA_WIDTH-1:0]  m_axil_wdata,
    output wire [M_STRB_WIDTH-1:0]  m_axil_wstrb,
    output wire                     m_axil_wvalid,
    input  wire                     m_axil_wready,
    input  wire                     m_axil_bvalid,
    output wire                     m_axil_bready
);

reg [1:0] ss;
localparam S0=2'b00, WRITE=2'b01, DATA=2'b10;

always @(posedge aclk)
begin
    if(arstn) ss<=0;
    else 
    begin
    case(ss)
        S0: 
            if(m_axil_awaddr)  //awaddr != NULL
            begin
                ss<=WRITE;
                //m_axil_arprot? 
                m_axil_awvalid<=1; 
                m_axil_awready<=1;
            end
            else ss<=S0;
            
        WRITE:
            if(m_axil_wready==0 || m_axil_wvalid==0) ss<=WRITE; 
            else
            begin
                ss<=DATA;
                m_axil_wready<=1;
                m_axil_wvalid<=1;
                m_axil_awvalid<=0;
                m_axil_awready<=0;
                m_axil_awaddr<=0;
                //m_axil_awstrb?
                //m_axil_wdata?
            end
            
        DATA:
            if(m_axil_bvalid && ~m_axil_bvalid) ss<=DATA;
            else
            begin
            ss<=S0;
            m_axil_wready<=0;
            m_axil_wvalid<=0;
            m_axil_awvalid<=0;
            m_axil_awready<=0;
            m_axil_awaddr<=0;
            m_axil_awstrb<=0;
            m_axil_wdatat<=0;
            m_axil_bvalid<=0;
            m_axil_bready<=0;
            end
      endcase
    end
end      
endmodule