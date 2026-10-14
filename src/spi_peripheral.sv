module spi_peripheral (
    input logic clk,
    input logic rst_n,
    input logic SCLK,
    input logic nCS,
    input logic COPI,
    
    output logic [7:0] en_reg_out_7_0,
    output logic [7:0] en_reg_out_15_8,
    output logic [7:0] en_reg_pwm_7_0,
    output logic [7:0] en_reg_pwm_15_8,
    output logic [7:0] pwm_duty_cycle
);
    localparam MAX_ADDRESS = 8'h04;
    localparam FRAME_WIDTH = 16;

    //sync SCLK, nCS, COPI
    logic SCLK_sync, nCS_sync, COPI_sync;

    sync sclk_sync_0 (
        .clk (clk),
        .din (SCLK),
        .dout(SCLK_sync)
    );

    sync nCS_sync_0 (
        .clk (clk),
        .din (nCS),
        .dout(nCS_sync)
    );
    
    sync COPI_sync_0 (
        .clk (clk),
        .din (COPI),
        .dout(COPI_sync)
    );


    logic nCS_posedge;
    logic SCLK_posedge;

    edge_detector #(
        .EDGE_TYPE(0)
    ) nCS_posedge_0 (
        .clk     (clk),
        .din     (nCS_sync),
        .rst_n   (rst_n),
        .din_edge(nCS_posedge)
    );
    edge_detector #(
        .EDGE_TYPE(0)
    ) SCLK_posedge_0 (
        .clk     (clk),
        .din     (SCLK_sync),
        .rst_n   (rst_n),
        .din_edge(SCLK_posedge)
    );

    logic transaction_ready, transaction_processed;
    logic [4:0] counter;
    logic [15:0] frame;
    //16 counter for frame data separation
    // Process SPI protocol in the clk domain
    //handle input shifting
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            transaction_ready <= 1'b0;
            // omitted code
            counter <= 0;
            frame <= 0;
        end else if (nCS_sync == 1'b0) begin
            // count here
            if (SCLK_posedge) begin
                //shift
                counter <= counter + 1;
                frame <= (frame << 1) | {15'b0,COPI_sync};

                if (counter == FRAME_WIDTH) begin
                    counter <= 0;
                end
            end
        end else begin
            // When nCS goes high (transaction ends), validate the complete transaction
            if (nCS_posedge) begin
                transaction_ready <= 1'b1;
            end else if (transaction_processed) begin
                // Clear ready flag once processed
                transaction_ready <= 1'b0;
            end
            // omitted code
        end
    end

    // Update registers only after the complete transaction has finished and been validated
    //check if address falls within range
    //write to output registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // omitted code
            en_reg_out_7_0 <= 0;
            en_reg_out_15_8 <= 0;
            en_reg_pwm_7_0 <= 0;
            en_reg_pwm_15_8 <= 0;
            pwm_duty_cycle <= 0;
            transaction_processed <= 1'b0;
        end else if (transaction_ready && !transaction_processed) begin
            // Transaction is ready and not yet processed
            // omitted code
            //slice frame only if write bit enabled
            /* verilator lint_off WIDTHEXPAND */
            if (frame[15] && (frame[14:8] < MAX_ADDRESS)) begin
                case (frame[14:8]) 
                7'h0: en_reg_out_7_0 <= frame[7:0];
                7'h1: en_reg_out_15_8 <= frame[7:0];
                7'h2: en_reg_pwm_7_0 <= frame[7:0];
                7'h3: en_reg_pwm_15_8 <= frame[7:0];
                7'h4: pwm_duty_cycle <= frame[7:0];
                default: ;
                endcase
            end

            // Set the processed flag
            transaction_processed <= 1'b1;
        end else if (!transaction_ready && transaction_processed) begin
            // Reset processed flag when ready flag is cleared
            transaction_processed <= 1'b0;
        end
    end
endmodule
