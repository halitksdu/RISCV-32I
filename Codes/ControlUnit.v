module ControlUnit(
  input [6:0] op,
  input [2:0] funct3,
  input funct7, Zero,
  output PCSrc,
  output reg ResultSrc, MemWrite, ALUSrcA, ALUSrcB, RegWrite, Rs1, 
  output wire RegSel,
  output reg [5:0] ALUControl,
  output reg [2:0] DataMemControl
  );
  reg [2:0] ALUOp;
  reg Branch;
  reg Jal;
  
  /** Main Decoder: */
  always @* begin
    if (op == 7'b0000011) begin               // I type (load) 
      RegWrite  = 1;
      ALUSrcA   = 1;
      ALUSrcB   = 1;
      MemWrite  = 0;
      ResultSrc = 1;
      Branch    = 0; 
      Jal				= 0;
      ALUOp     = 3'd0;
    
    end else if (op == 7'b0010011) begin      // I type (R imm) 
      RegWrite  = 1;
      ALUSrcA   = 1;
      ALUSrcB   = 1;
      MemWrite  = 0;
      ResultSrc = 0; 
      Branch    = 0; 
      Jal				= 0;
      ALUOp     = 3'd1;
      
    end else if (op[4:0] == 5'b10111) begin   // U type 
			RegWrite  = 1;
			ALUSrcA   = 0;
			ALUSrcB   = 1;
			MemWrite  = 0;
			ResultSrc = 0; 
			Branch    = 0; 
			Jal				= 0;
			ALUOp     = 3'd3;
    	
    end else if (op == 7'b0100011) begin      // S type 
      RegWrite  = 0;
      ALUSrcA   = 1;
      ALUSrcB   = 1;
      MemWrite  = 1;
      //ResultSrc = 0; 
      Branch    = 0; 
      Jal				= 0;
      ALUOp     = 3'd4;
    
    end else if (op == 7'b0110011) begin      // R type
      RegWrite  = 1;
      ALUSrcA   = 1;
      ALUSrcB   = 0;
      MemWrite  = 0;
      ResultSrc = 0;
      Branch    = 0;
      Jal				= 0; 
      ALUOp     = 3'd2;
    
    end else if (op == 7'b1100011) begin      // B type
      RegWrite  = 0;
      ALUSrcA   = 1;
      ALUSrcB   = 0;
      MemWrite  = 0;
      Rs1				= 1;
      ResultSrc = 0;
      Branch    = 1; 
      Jal				= 0;
      ALUOp     = 3'd5;
      
    end else if (op == 7'b1100111) begin      // I type (jalr)
      RegWrite  = 1;
      Rs1				= 0;
      Jal				= 1;
      
    end else if (op == 7'b1101111) begin      // J type (jal)
      RegWrite  = 1;
      Rs1				= 1;
      Jal				= 1;
    
    end else begin 
      RegWrite  = 0;
      ALUSrcA   = 1;
      ALUSrcB   = 0;
      MemWrite  = 0;
      ResultSrc = 0;
      Branch    = 0; 
      Jal				= 0;
      ALUOp     = 3'd0;
    end
  end
  
  assign RegSel = ~Jal;
  assign PCSrc = (Zero && Branch) || Jal;
    
  /** ALU Decoder: */
  always @* begin
    
    // I TYPE (load):
    if (ALUOp == 3'd0) begin 
            
      ALUControl = 6'd0;	// adres hesaplama
    	if 			(funct3 == 3'd0)  DataMemControl = 3'd0; 	//lb   
    	else if (funct3 == 3'd1)  DataMemControl = 3'd1; 	//lh 
    	else if (funct3 == 3'd2)  DataMemControl = 3'd2; 	//lw 
    	else if (funct3 == 3'd4)  DataMemControl = 3'd3; 	//lbu
    	else if (funct3 == 3'd5)  DataMemControl = 3'd4; 	//lwu
    	else 											DataMemControl = 3'd0;	
    	
    	
    // I TYPE (load):
    end else if (ALUOp == 3'd1) begin
    	
    	if      (funct3 == 3'b000) 										ALUControl = 6'd0;  //addi
      else if (funct3 == 3'b001) 										ALUControl = 6'd5;  //slli
      else if (funct3 == 3'b010)									  ALUControl = 6'd13; //slti
      else if (funct3 == 3'b011)										ALUControl = 6'd10; //sltiu
      else if (funct3 == 3'b100)										ALUControl = 6'd3;  //xori
      else if (funct3 == 3'b101 & funct7 == 1'b0) 	ALUControl = 6'd6;  //srli
      else if (funct3 == 3'b101 & funct7 == 1'b1) 	ALUControl = 6'd7;  //srai
      else if (funct3 == 3'b110) 										ALUControl = 6'd4;  //ori
      else if (funct3 == 3'b111) 										ALUControl = 6'd2;  //andi
      else 																					ALUControl = 6'd0;
    
    
    // U TYPE:
    end else if (ALUOp == 3'd3) begin
    	
    	if (op[5] == 1) ALUControl = 6'd63; //lui
    	else					  ALUControl = 6'd0; //auipc
    	
    	
    // S TYPE:
    end else if (ALUOp == 3'd4) begin
    
    	ALUControl = 6'd0;																										
      if		  (funct3 == 3'd0) DataMemControl = 3'd5;	//sb
      else if (funct3 == 3'd1) DataMemControl = 3'd6;	//sh
      else if (funct3 == 3'd2) DataMemControl = 3'd7;	//sw
      
      
    // R TYPE:
    end else if (ALUOp == 3'd2) begin 
      
      if      ({funct3,funct7} == 4'b0000) 	ALUControl = 6'd0;  //add
      else if ({funct3,funct7} == 4'b0001) 	ALUControl = 6'd1;  //sub 
      else if ({funct3,funct7} == 4'b0010) 	ALUControl = 6'd5;  //sll
      else if ({funct3,funct7} == 4'b0100) 	ALUControl = 6'd13; //slt 
      else if ({funct3,funct7} == 4'b0110) 	ALUControl = 6'd10; //sltu
      else if ({funct3,funct7} == 4'b1000) 	ALUControl = 6'd3;  //xor
      else if ({funct3,funct7} == 4'b1010) 	ALUControl = 6'd6;  //srl 
      else if ({funct3,funct7} == 4'b1011) 	ALUControl = 6'd7;  //sra 
      else if ({funct3,funct7} == 4'b1100) 	ALUControl = 6'd4;  //or
      else if ({funct3,funct7} == 4'b1110) 	ALUControl = 6'd2;  //and
      else 																	ALUControl = 6'd0;
    
    
    // B TYPE:
    end else if (ALUOp == 3'd5) begin
    	
    	if      (funct3 == 3'b000) 	ALUControl = 6'd8;  //beq
 			else if (funct3 == 3'b001) 	ALUControl = 6'd11;	//bne
 			else if (funct3 == 3'b100)	ALUControl = 6'd13;	//blt
 			else if (funct3 == 3'b101)	ALUControl = 6'd14;	//bge
 			else if (funct3 == 3'b110)	ALUControl = 6'd10;	//bltu
 			else if (funct3 == 3'b111) 	ALUControl = 6'd9;	//bgeu
 			else 												ALUControl = 6'd8;  	      

    
    // Default:
    end else ALUControl = 6'dX;
    
  end



endmodule