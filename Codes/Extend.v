module Extend(
    input [31:0] Instr,
    output reg [31:0] ImmExt);
    wire [6:0] op = Instr[6:0];

    always @(Instr) begin
      if (op == 7'b0000011 || op == 7'b0010011 || op == 7'b1100111) begin 	// I type 
        ImmExt = {{21{Instr[31]}},Instr[30:20]};

      end else if (op == 7'b0100011) begin															 		// S type
        ImmExt = {{21{Instr[31]}},Instr[30:25],Instr[11:7]};

      end else if (op == 7'b1100011) begin 																	// B type
        ImmExt = {{20{Instr[31]}},Instr[7],Instr[30:25],Instr[11:8],1'b0};        

      end else if (op == 7'b0110111 || op == 7'b0010111) begin							// U type
        ImmExt = {{Instr[31:12]},12'd0};

      end else if (op == 7'b1101111) begin 																	// J type
        ImmExt = {{12{Instr[31]}},Instr[19:12],Instr[20],Instr[30:21],1'b0};

      end else ImmExt = 32'd0;
    end
endmodule