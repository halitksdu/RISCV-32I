module InstrMem(
    input [11:0] A,
    output [31:0] RD
    );
    reg [31:0] memory [0:1920];
		
    initial $readmemh("C:\\Users\\halit.kosdu\\Desktop\\Documents\\Assignment8\\big_test.s.hex",memory);
    assign RD = memory[A];

endmodule