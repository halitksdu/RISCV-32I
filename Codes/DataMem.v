module DataMem(
  input clk, WE,
  input [2:0] DataControl, 
  input [12:0] Adress,
  input [31:0] WrData,
  output reg [31:0] Read
  );
  integer i;
  reg [31:0] Memory [0:4095];
  reg [31:0] MemoryCur;
  
  initial for (i=0 ; i<4096 ; i = i+1) Memory[i] = 32'd0;
  
  /** Read */ 
  always @* begin 	// WE 0 durumu (kombinezonsal)
  	
  	if (WE == 0) begin	
  		MemoryCur = Memory[Adress];
			if 			(DataControl == 3'd0)		Read = {{24{MemoryCur[7]}},MemoryCur[7:0]};			//lb
			else if (DataControl == 3'd1)		Read = {{16{MemoryCur[15]}},MemoryCur[15:0]};		//lh
			else if (DataControl == 3'd2)		Read = MemoryCur;																//lw	
			else if (DataControl == 3'd3)		Read = {24'd0,MemoryCur[7:0]};			 						//lbu
			else if (DataControl == 3'd4)		Read = {16'd0,MemoryCur[15:0]};									//lhu
			else 													 	Read = MemoryCur;
  	end
  	
  end
  
  
	/** Write */ 
  always @(posedge clk) begin // WE 1 durumu
  
  	if(WE) begin
  		
  		Memory[Adress] <= WrData;  
  		if			(DataControl == 3'd5) Memory[Adress][7:0] <= WrData[7:0];		//sb  
  		else if (DataControl == 3'd6) Memory[Adress][15:0] <= WrData[15:0];	//sh
  		else if (DataControl == 3'd7) Memory[Adress] <= WrData;							//sw
  		else 													Memory[Adress] <= WrData;													
  		
		end
		
	end	
		
		
		
endmodule