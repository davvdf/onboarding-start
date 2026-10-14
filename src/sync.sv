module sync (
    input logic clk,
    input logic din,
    output logic dout
);
    logic temp1, temp2;
    always_ff @(posedge clk) begin
        temp1 <= din;
        temp2 <= temp1;
    end
    assign dout = temp2;
endmodule