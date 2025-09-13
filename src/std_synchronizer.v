module std_synchronizer (
    input wire clk,
    input wire rst_n,
    input wire d_in,
    output reg d_out
);
    reg mid;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            d_out <= '0;
            mid <= '0;
        end else begin
            mid <= d_in;
            d_out <= mid;
        end
    end
endmodule