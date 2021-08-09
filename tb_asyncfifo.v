`timescale 1ns/1ps
module tb_asyncfifo;
reg rd_clk, wr_clk, reset;
wire [7:0]data_out;
wire wr_full, rd_empty;

asyncfifo async(data_out, wr_full, rd_empty, 
				 rd_clk, wr_clk, reset);
				 
initial 
begin
reset=1'b1;
#5 reset=1'b0;
end
initial
begin
wr_clk=1'b0;
rd_clk=1'b0;
end
always
begin
#10 wr_clk=~wr_clk;
end
always
begin
#100 rd_clk=~rd_clk;
end
initial
#1000 $finish;
endmodule



