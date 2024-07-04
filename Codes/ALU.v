module ALU(
    input [31:0] A,
    input [31:0] B,
    input [5:0] op,
    output Zero,
    output reg [31:0] out);
    
    // Function control:
    wire arith_op;
    wire [1:0] logic_op;
    wire [1:0] shifter_op;
    wire [2:0] cmp_op;
    wire [1:0] unit_sel;

    FunctionControl Control(op, arith_op, logic_op,shifter_op,cmp_op,unit_sel);


    // Modüller:
    wire [31:0] out_arith;
    ArithmeticUnit  Arith(A, B, arith_op, out_arith);

    wire [31:0] out_logic;
    LogicUnit       Logic( A, B, logic_op, out_logic);

    wire [31:0] out_shifter;
    ShifterUnit     Shift(A, B, shifter_op, out_shifter);

    wire [31:0] out_comp;
    ComparisonUnit  Comparision( A, B, cmp_op, out_comp);
		

    // Secici:
    always @(*) begin
        case(unit_sel) 
            2'b00: begin
                out = out_arith;
            end
            2'b01: begin
                out = out_logic;
            end
            2'b10: begin
                out = out_shifter;
            end
            2'b11: begin
                out = out_comp;
            end
        endcase
    end
    
    assign Zero = (out_comp == 32'd1) ? 1'b1 : 1'b0;
    
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module FunctionControl(
    input [5:0] op,
    output reg arith_op, 
    output reg [1:0] logic_op,
    output reg [1:0] shifter_op,
    output reg [2:0] cmp_op,
    output reg [1:0] unit_sel);

    parameter ADD = 6'd0;
    parameter SUB = 6'd1;
    parameter AND = 6'd2;
    parameter XOR = 6'd3;
    parameter OR  = 6'd4;
    parameter SLL = 6'd5;     // Shift Left Logical 
    parameter SRL = 6'd6;     // Shift Right Logical 
    parameter SRA = 6'd7;     // Shift Right Arithmetic
    parameter EQ  = 6'd8;     // equal
    parameter GRTU= 6'd9;     // Greater than or Equal (unsigned)
    parameter GRT = 6'd14;		// Greater than or Equal (signed)
    parameter SLTU= 6'd10;    // Set Less Than (unsigned)
    parameter SLT = 6'd13;    // Set Less Than (signed)
    parameter NEQ = 6'd11;    // not equal
    parameter GR  = 6'd12;    // Greater Than
     
    parameter EMP = 6'd63;		// nothing
    
    reg [23:0] alu_op_string;
    always@(*) begin
    	case(op)
    		ADD : alu_op_string = "ADD";
    	endcase
    end
    
    

    always @(*) begin
        case(op) 
            ADD: begin
                unit_sel = 2'd0;                
                arith_op = 1'b0;                
            end 
            SUB: begin
                unit_sel = 2'd0;
                arith_op = 1'b1;
            end
            AND: begin
                unit_sel = 2'd1;
                logic_op = 2'd0;
            end 
            XOR: begin
                unit_sel = 2'd1;
                logic_op = 2'd1;
            end
            OR: begin
                unit_sel = 2'd1;
                logic_op = 2'd2;
            end 
            SLL: begin
                unit_sel = 2'd2;
                shifter_op = 2'd0;
            end
            SRL: begin
                unit_sel = 2'd2;
                shifter_op = 2'd1;
            end 
            SRA: begin
                unit_sel = 2'd2;
                shifter_op = 2'd2;
            end
            EQ: begin
                unit_sel = 2'd3;
                cmp_op = 3'd0;
            end 
            GRTU: begin
                unit_sel = 2'd3;
                cmp_op = 3'd1;
            end
            GRT: begin
            		unit_sel = 2'd3;
                cmp_op = 3'd6;
            end
            SLTU: begin
                unit_sel = 2'd3;
                cmp_op = 3'd2;
            end 
            SLT: begin
                unit_sel = 2'd3; 
                cmp_op = 3'd5;   
            end
            NEQ: begin
                unit_sel = 2'd3;
                cmp_op = 3'd3;
            end
            GR: begin
                unit_sel = 2'd3;
                cmp_op = 3'd4;
            end
            EMP: begin
            		unit_sel = 2'd1;
                logic_op = 2'd3;
            end
            default: begin
                arith_op = 0;
                logic_op = 0;
                shifter_op = 0;
                cmp_op = 0;
                unit_sel = 0;
            end
        endcase
    end
endmodule

//

module ArithmeticUnit(
    input [31:0] A,
    input [31:0] B,
    input arith_op,
    output [31:0] out );
    
    toplayici arithmetic(A, B, arith_op, out);
    
endmodule

///////////////////////////////////////////////////////////////////////////////

module toplayici(
    input [31:0]  A_i,
    input [31:0]  B_i,
    input         Sel_i,   // select 0 ise toplama, select 1 ise ��karma 
    output [31:0] Sum_o);
    
    wire [31:0] B_xor;
    wire [31:0] Carry;
    genvar i;
    generate for(i=0; i < 32; i = i+1) begin
        assign B_xor[i] = B_i[i] ^ Sel_i;
        if(i==0) 
            full_adder f(A_i[0],B_xor[0], Sel_i, Sum_o[0], Carry[0]); 
        else begin
            full_adder f(A_i[i], B_xor[i], Carry[i-1], Sum_o[i], Carry[i]); end  
    end endgenerate
    
endmodule

///////////////////////////////////////////////////////

module full_adder(
           input wire A,
           input wire B, 
           input wire Cin,
           output wire Sout,
           output wire Cout );
    
    wire w1,w2,w3;
    
    xor  (w1,A,B);
    and  (w2,w1,Cin); 
    and  (w3,A,B);
        
    xor  (Sout,w1,Cin);
    or   (Cout,w2,w3);
endmodule

//

module LogicUnit(
    input [31:0] A,
    input [31:0] B,
    input [1:0] logic_op,
    output reg [31:0] out );
    
    always @(logic_op,A,B) begin 
      if (logic_op == 2'b00) begin  				// AND
        out = A&B;
      end else if (logic_op == 2'b01) begin // XOR
        out = A^B;
      end else if (logic_op == 2'b10) begin // OR
        out = A|B;
      end else begin												// nothing
      	out = B;
      end
    end  
    
endmodule

//

module ShifterUnit(
    input [31:0] A,
    input [31:0] B,
    input [1:0] shifter_op,
    output reg [31:0] out );
    
    // Shift Left Logical:
    reg [31:0] shifter_leftlog;
    always @(A,B,shifter_op) begin
        shifter_leftlog = (B[0])? {A[30:0],1'b0} 								: A;                               
        shifter_leftlog = (B[1])? {shifter_leftlog[29:0],2'b0}  : shifter_leftlog; 
        shifter_leftlog = (B[2])? {shifter_leftlog[27:0],4'b0}  : shifter_leftlog; 
        shifter_leftlog = (B[3])? {shifter_leftlog[23:0],8'b0}  : shifter_leftlog; 
        shifter_leftlog = (B[4])? {shifter_leftlog[15:0],16'b0} : shifter_leftlog;
    end 

    
    // Shift Right Logical:
    reg [31:0] shifter_rightlog;
    always @(A,B,shifter_op) begin
        shifter_rightlog = (B[0])? {1'b0,A[31:1]} 								  : A;                                  
        shifter_rightlog = (B[1])? {2'b0, shifter_rightlog[31:2]}	  : shifter_rightlog;           
        shifter_rightlog = (B[2])? {4'b0, shifter_rightlog[31:4]} 	: shifter_rightlog;        
        shifter_rightlog = (B[3])? {8'b0, shifter_rightlog[31:8]} 	: shifter_rightlog;      
        shifter_rightlog = (B[4])? {16'b0,shifter_rightlog[31:16]}	: shifter_rightlog;    
    end

    // Shift Right Aritmetic:
    reg [31:0] shifter_rightArit;
    always @(A,B,shifter_op) begin
        shifter_rightArit = (B[0])? {A[31],A[31:1]} : A;  
        shifter_rightArit = (B[1])? {{2{A[31]}},shifter_rightArit[31:2]} : shifter_rightArit;      
        shifter_rightArit = (B[2])? {{4{A[31]}},shifter_rightArit[31:4]} : shifter_rightArit;   
        shifter_rightArit = (B[3])? {{8{A[31]}},shifter_rightArit[31:8]} : shifter_rightArit; 
        shifter_rightArit = (B[4])? {{16{A[31]}},shifter_rightArit[31:16]}: shifter_rightArit;
    end

    // Seçici modül:
    always @(A,B,shifter_op) begin

        if (shifter_op == 2'd0) begin           //Shift Left Logical
            out = shifter_leftlog;

        end else if (shifter_op == 2'd1) begin  //Shift Right Logical
            out = shifter_rightlog;

        end else if (shifter_op == 2'd2) begin  //Shift Right Aritmetic
            out = shifter_rightArit;
        end else begin
            out = 32'd0;
        end
    end   

    
    
endmodule

//

module ComparisonUnit(
    input [31:0] A,
    input [31:0] B,
    input [2:0] cmp_op,
    output reg [31:0] out  );

    // Equal and Greater than:
    wire equal;
    wire greatThan;
    assign equal = (A==B)     ? 1'b1 : 1'b0;
    assign greatThan = (A>=B) ? 1'b1 : 1'b0;
    

    always @(A,B,cmp_op) begin
        if(cmp_op == 3'd0) begin              // Equal
            out = {31'd0,equal};

        end else if (cmp_op == 3'd1) begin   // Greater than or Equal
            out = {31'd0,greatThan};

        end else if (cmp_op == 3'd2) begin   // Less Than Unsigned
            out = {31'd0,(!greatThan)};

        end else if (cmp_op == 3'd3) begin   // Not equal
            out = {31'd0,!equal};

        end else if(cmp_op == 3'd4) begin   // Greater than 
            out = {31'd0,(greatThan && !equal)};
            
        end else if(cmp_op == 3'd5) begin   // Less Than (Signed)
            out = {31'd0, $signed(A) < $signed(B)};
            
        end else if(cmp_op == 3'd6) begin 	// Greater than or Equal (Signed)
            out = {31'd0, $signed(A) >= $signed(B)};
            
        end else begin
        		out = 32'd0;
        
        end
    end


endmodule