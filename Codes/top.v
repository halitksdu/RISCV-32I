module top(
input clk,
input reset
);

/** PC */
wire PCSrc;
reg [31:0] PC;
wire [31:0] PCNext;

always @(posedge clk) begin
	if (!reset) PC <= 32'h8000_0000;  
	else begin 
		if (PCSrc == 1'b1)	PC <= PCNext;		
		else 								PC <= PC + 4;
	end
end


/** Instruction Memory */
wire [31:0] Instr;

InstrMem IM(
.A(PC[13:2]),
.RD(Instr)
);


/** Control Unit */
wire Zero;
wire ResultSrc;
wire MemWrite;
wire ALUSrcA;
wire ALUSrcB;
wire RegWrite;
wire Rs1;
wire RegSel;
wire [5:0] ALUControl;
wire [2:0] DataMemControl;
wire [1:0] DataWrContr;

ControlUnit CU(
.op			(Instr[6:0]),                                  
.funct3		(Instr[14:12]),                              
.funct7		(Instr[30]), 
.Zero		(Zero),                              
.PCSrc		(PCSrc),                                    
.ResultSrc	(ResultSrc), 
.MemWrite	(MemWrite), 
.ALUSrcA	(ALUSrcA), 
.ALUSrcB  (ALUSrcB),
.RegWrite	(RegWrite),
.Rs1 (Rs1),
.RegSel (RegSel),
.ALUControl	(ALUControl),    
.DataMemControl (DataMemControl)        
);


/** Register File */
wire [31:0] WrResult;
wire [31:0] WrData;
wire [31:0] Read1;
wire [31:0] Read2;
assign WrData = RegSel ? WrResult : (PC + 4);  // deneme

RegFile RF(
.clk		(clk), 
.WrEn		(RegWrite),
.RdAdr1		(Instr[19:15]), 
.RdAdr2		(Instr[24:20]), 
.WrAdr		(Instr[11:7]),
.WrData		(WrData),
.Read1		(Read1),
.Read2		(Read2)
);


/** Extend */
wire [31:0] ImmExt;

Extend Ext(
.Instr		(Instr),
.ImmExt		(ImmExt)
);    


/** ALU */
wire [31:0] ALUResult;
wire [31:0] SrcA;
wire [31:0] SrcB;
assign SrcA = ALUSrcA ? Read1:PC;
assign SrcB = ALUSrcB ? ImmExt:Read2;

ALU	Alu(
.A		(SrcA),
.B		(SrcB),
.op		(ALUControl),
.Zero	(Zero),
.out	(ALUResult) 
);


/** PC Target */
wire [31:0] RsPC;
assign RsPC = Rs1 ? PC : Read1;
assign PCNext = RsPC + ImmExt;


/** Data Memory */
wire [31:0] ReadData; 

DataMem DataMemory(
.clk		(clk), 
.WE			(MemWrite),
.DataControl (DataMemControl),
.Adress		(ALUResult),
.WrData		(Read2),
.Read		(ReadData)
);

assign WrResult = ResultSrc ? ReadData : ALUResult; // Result


/** Verileri Kaydetme */
integer file_id;
initial	file_id = $fopen ("C://Users//halit.kosdu//Desktop//Documents//Assignment8//testme.txt", "w");

always @(posedge clk) begin
 
	if (RegWrite == 1 && ResultSrc == 1) begin 
		$fwrite(file_id, "0x%h (0x%h) x%d 0x%h mem 0x%h\n",PC,Instr,Instr[11:7],WrData,ALUResult);
			
	end else if (RegWrite == 1 && Instr[11:7] != 5'd0) begin
		$fwrite(file_id, "0x%h (0x%h) x%d 0x%h \n",PC,Instr,Instr[11:7],WrData);
			
	end else if (MemWrite == 1) begin
		$fwrite(file_id, "0x%h (0x%h) mem 0x%h 0x%h \n",PC,Instr,ALUResult,Read2);
		
	end else begin 
		$fwrite(file_id, "0x%h (0x%h) \n",PC,Instr);
	end
	
end    
    
    
endmodule