module asyncfifo (data_out, wr_full, rd_empty, 
				 rd_clk, wr_clk, reset);

parameter WIDTH = 8;

output [WIDTH-1 : 0] data_out;
output wr_full;
reg empty;
output rd_empty;
input rd_clk, wr_clk;
input reset;
reg [7:0] t_ptr;
wire [7:0]data_in;

reg [4 : 0] rd_pointer,  rd_sync_1, rd_sync_2;
reg [4 : 0] wr_pointer,  wr_sync_1, wr_sync_2;
wire [4 : 0] wr_pointer_g;
wire [4 : 0] rd_pointer_g;
parameter DEPTH = 16;

reg [WIDTH-1 : 0] mem [DEPTH-1 : 0];

wire [4 : 0] rd_pointer_sync;
wire [4 : 0] wr_pointer_sync;

//--write logic--//
memory dut(t_ptr,data_in);
always @(posedge wr_clk or  posedge reset) begin
	if (reset) begin
		// reset
		wr_pointer <= 0;
		t_ptr<=8'b0;
	end
	else if (wr_full == 1'b0) begin
		wr_pointer <= wr_pointer + 1;
		mem[wr_pointer[3: 0]]<= data_in;
		t_ptr<=t_ptr+1;
	end
end
//--read pointer synchronizer controled by write clock--//
always @(posedge wr_clk) begin
	rd_sync_1 <= rd_pointer_g;
	rd_sync_2 <= rd_sync_1;
end
//--read logic--//
always @(posedge rd_clk or posedge reset) begin
	if (reset) begin
		// reset
		rd_pointer <= 0;
		//empty <= 1'b0;
	end
	else if (empty != 1'b1) begin
		rd_pointer <= rd_pointer + 1;
	end
end
//write pointer synchronizer controlled by read clock//
always @(posedge rd_clk) begin
	wr_sync_1 <= wr_pointer_g;
	wr_sync_2 <= wr_sync_1;
end

//write full flag

assign wr_full  = ((wr_pointer[3 : 0] == rd_pointer_sync[3 : 0]) && 
				(wr_pointer[4] != rd_pointer_sync[4] ));
				
				
//read empty flag
always@(*)
begin
if(wr_pointer_sync == rd_pointer)
empty=1;
else
empty=0;
end


assign data_out = mem[rd_pointer[3:0]];
assign rd_empty=empty;

//--binary code to gray code--//
assign wr_pointer_g = wr_pointer ^ (wr_pointer >> 1);
assign rd_pointer_g = rd_pointer ^ (rd_pointer >> 1);
//gray code to binary code//						
assign wr_pointer_sync[4]=wr_sync_2[4];
assign wr_pointer_sync[3]=wr_sync_2[4]^wr_sync_2[3];
assign wr_pointer_sync[2]= wr_sync_2[4]^wr_sync_2[3]^wr_sync_2[2];
assign wr_pointer_sync[1]=wr_sync_2[4]^wr_sync_2[3]^wr_sync_2[2]^wr_sync_2[1];
assign wr_pointer_sync[0]=wr_sync_2[4]^wr_sync_2[3]^wr_sync_2[2]^wr_sync_2[1]^wr_sync_2[0];




assign rd_pointer_sync[4]=rd_sync_2[4];
assign rd_pointer_sync[3]=rd_sync_2[4]^rd_sync_2[3];
assign rd_pointer_sync[2]=rd_sync_2[4]^rd_sync_2[3]^rd_sync_2[2];
assign rd_pointer_sync[1]=rd_sync_2[4]^rd_sync_2[3]^rd_sync_2[2]^rd_sync_2[1];
assign rd_pointer_sync[0]=rd_sync_2[4]^rd_sync_2[3]^rd_sync_2[2]^rd_sync_2[1]^rd_sync_2[0];



						
endmodule
//memory block
module memory(t_ptr,data);
//input wr_clk;
integer i;
input [7:0]t_ptr;
output [7:0]data;
reg [7 : 0] memo [255 : 0];

assign data=memo[t_ptr];
initial
begin
for (i=0;i<=255;i=i+1)
memo[i]<=i;
end


endmodule
