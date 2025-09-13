module spi_peripheral #(
    
) (
    input wire nCS,
    input wire SCLK,
    input wire COPI,
    input wire clk,
    input wire rst_n,
    output reg [15:0] en_out,
    output reg [15:0] en_pwm_mode,
    output reg [7:0] pwm_duty_cycle
);
    localparam max_address = 8'h4;
    reg [3:0] counter;
    reg nCS_sync;
    reg SCLK_sync;
    reg COPI_sync;

    //sync signals
    std_synchronizer spi_sync_inst[3](
        .clk(clk),
        .rst_n(rst_n),
        .d_in({nCS,SCLK,COPI}),
        .d_out({nCS_sync,SCLK_sync,COPI_sync})
    );
    reg SCLK_edge_reg;
    wire SCLK_posedge;
    wire SCLK_negedge;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            SCLK_edge_reg <= '0;
        end else begin
            SCLK_edge_reg <= SCLK_sync;
        end
    end
    assign SCLK_posedge = ~SCLK_edge_reg & SCLK_sync;
    assign SCLK_negedge = SCLK_edge_reg & ~SCLK_sync;

    //frames
    //shift masked bits onto capture reg
    reg [15:0] capture_reg;
    reg transaction_ready;
    reg transaction_valid;
    reg transaction_in_progress;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            en_out <= '0;
            en_pwm_mode <= '0;
            pwm_duty_cycle <= '0;
        end else if (!nCS_sync) begin
            if (SCLK_posedge) begin 
                counter <= counter + 1'b1;
                capture_reg <= capture_reg << 1;
            end
            if (SCLK_negedge) begin
                if (~counter[3]) begin
                    capture_reg[0] <= COPI_sync;
                end else begin
                    transaction_ready <= 1'b1;
                end
            end
        end else begin
            
        end
    end
    //validation
    //decoder
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            
        end
        //transaction finished at the end
        if (transaction_in_progress) begin
            
        end
    end
endmodule