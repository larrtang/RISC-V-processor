module physical_memory
(
    input clk,
    input read,
    input write,
    input [31:0] address,
    input [255:0] wdata,
    output logic resp,
    output logic error,
    output logic [255:0] rdata
);

timeunit 1ns;
timeprecision 1ns;

parameter DELAY_MEM = 250;

logic [255:0] mem [2**(22)]; //only get fraction of 4GB addressable space due to modelsim limits
logic [21:0] internal_address;
logic internal_read, internal_write;
logic [255:0] internal_wdata;
logic ready;

/* Initialize memory contents from memory.lst file */
initial
begin
    $readmemh("memory.lst", mem);
end

enum int unsigned {
    idle,
    busy,
    fail,
    respond
} state, next_state;

always @(posedge clk)
begin
    /* Default */
    error = 0;
    resp = 1'b0;
    rdata = 32'bX;

    next_state = state;

    case(state)
        idle: begin
            if (read | write) begin
                internal_address = address[26:5];
                internal_read = read;
                internal_write = write;
                internal_wdata = wdata;
                next_state = busy;
                ready <= #DELAY_MEM 1;
            end
        end

        busy: begin
            if ((internal_address != address[26:5]) || (internal_read != read) || (internal_write != write) || (internal_write && (internal_wdata != wdata))) begin
                $display("Invalid input: Change in input value");
                next_state = fail;
            end

            else if (ready == 1) begin
                if (write)
                begin
                   mem[internal_address] = wdata;
                end

                rdata = mem[internal_address];
                resp = 1;

                next_state = respond;
            end
        end

        fail: begin
            error = 1;
            if (ready == 1) begin
                next_state = respond;
            end
        end

        respond: begin
            ready <= 0;
            next_state = idle;
        end

        default: next_state = idle;
    endcase
end

always_ff @(posedge clk)
begin : next_state_assignment
    state <= next_state;
end

endmodule : physical_memory
