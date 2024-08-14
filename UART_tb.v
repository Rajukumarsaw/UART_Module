module UART_TB;

reg clk;
reg reset;
reg tx_start;
reg [7:0] data_in;
wire tx_serial;
wire tx_done;
wire rx_done;
wire [7:0] data_out;
wire baud_rate_clk;

// Instantiate the Baud Rate Generator
Baud_Rate_Gen baud_gen (
    .clk(clk),
    .reset(reset),
    .baud_rate_clk(baud_rate_clk)
);

// Instantiate the UART Transmitter
UART_TX tx (
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .data_in(data_in),
    .baud_rate_clk(baud_rate_clk),
    .tx_serial(tx_serial),
    .tx_done(tx_done)
);

// Instantiate the UART Receiver
UART_RX rx (
    .clk(clk),
    .reset(reset),
    .rx_serial(tx_serial),
    .baud_rate_clk(baud_rate_clk),
    .data_out(data_out),
    .rx_done(rx_done)
);

initial begin
    // Initialize signals
    clk = 0;
    reset = 1;
    tx_start = 0;
    data_in = 8'h00;
    #20 reset = 0;

    // Transmit a byte
    #40 data_in = 8'hA5;
    tx_start = 1;
    #10 tx_start = 0;

    // Wait for transmission to complete
    wait(tx_done);
    #100;

    // Check if the receiver received the correct data
    if (data_out == 8'hA5) begin
        $display("Test Passed: Received Data = %h", data_out);
    end else begin
        $display("Test Failed: Received Data = %h", data_out);
    end
    $stop;
end

// Clock generation
always #5 clk = ~clk;

endmodule
