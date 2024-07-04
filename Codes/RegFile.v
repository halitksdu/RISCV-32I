module RegFile(
input clk, WrEn,
input [4:0] RdAdr1, RdAdr2, WrAdr,
input [31:0] WrData,
output [31:0] Read1,
output [31:0] Read2
);
integer i;

reg [31:0] RegMem [0:31];
initial for (i=0 ; i<32 ; i=i+1) RegMem[i]= 32'd0;


always @(posedge clk) begin
  
  if(WrEn && WrAdr!=5'd0) begin
      RegMem[WrAdr] <= WrData;
  end
end

assign Read1 = RegMem[RdAdr1];
assign Read2 = RegMem[RdAdr2];

endmodule