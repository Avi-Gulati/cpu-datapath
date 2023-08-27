module mux
    #(
        parameter N = 32
    )
    (
        input logic sel,
        input logic [N-1:0] a , b , 
        output logic [N-1:0] f
    );

    assign f = sel ? b : a ;

endmodule