module eight_one_32b_mux
    #(
        parameter N = 32
    )
    (
        input logic [N-1:0] i7, i6, i5, i4, i3, i2, i1, i0, 
        input logic [2:0] s, 
        output logic [N-1:0] f 
    );

    // assign f = (!s[2]&!s[1]&!s[0]&i0) | (!s[2]&!s[1]&s[0]&i1) | (!s[2]&s[1]&!s[0]&i2) | 
    // (!s[2]&s[1]&s[0]&i3) | (s[2]&!s[1]&!s[0]&i4) | (s[2]&!s[1]&s[0]&i5) | (s[2]&s[1]&!s[0]&i6) | (s[2]&s[1]&!s[0]&i7);
    // nest conditionals over here 

    assign f = !s[2]&!s[1]&!s[0] ? i0 : !s[2]&!s[1]&s[0] ? i1: 
    !s[2]&s[1]&!s[0] ? i2: !s[2]&s[1]&s[0] ? i3: s[2]&!s[1]&!s[0] ? i4: 
    s[2]&!s[1]&s[0] ? i5: s[2]&s[1]&!s[0] ? i6: i7;

endmodule 