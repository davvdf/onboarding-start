module edge_detector #(parameter EDGE_TYPE = 0)(
    input logic clk,
    input logic din,
    input logic rst_n,
    output logic din_edge 
);
    //EDGE_TYPE = 0 -> falling
    //EDGE_TYPE = 1 -> risiing
    logic din_delayed;
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            din_delayed <= 0;
        end else begin
            din_delayed <= din;
        end
    end

    always_comb begin
        if (EDGE_TYPE == 0) begin
            din_edge = (din & ~din_delayed);
        end else begin
            din_edge = (~din & din_delayed);
        end
    end
endmodule
