
import Base.alignment

# A bit of a mess but does the job...
function Base.print_matrix_row(io::IO,
        X::AbstractBlockVecOrMat, A::Vector,
        i::Integer, cols::AbstractVector, sep::AbstractString)
    cumul = 0
    block = 1

    row_buf = IOBuffer()

    row_sum = cumsum(X.block_sizes[1][1:end-1])
    if ndims(X) == 2
        col_sum = cumsum(X.block_sizes[2][1:end-1])
    end

    for k = 1:length(A)
        n_chars = 0
        j = cols[k]

        if isassigned(X,Int(i),Int(j)) # isassigned accepts only `Int` indices
            x = X[i,j]
            a = Base.alignment(io, x)
            sx = sprint(0, Base.showcompact_lim, x, env=io)
        else
            a = Base.undef_ref_alignment
            sx = Base.undef_ref_str
        end
        l = repeat(" ", A[k][1]-a[1]) # pad on left and right as needed
        r = repeat(" ", A[k][2]-a[2])
        prettysx = Base.replace_in_print_matrix(X,i,j,sx)
        print(io, l, prettysx, r)

        n_chars += length(l) + length(prettysx) + length(r) + 2

        cumul += 1
        if ndims(X) == 2
            if block < length(X.block_sizes[2]) && cumul == X.block_sizes[2, block]
                block += 1
                cumul = 0
                print(io, "  │")
                n_chars += 3
            end
        end

        if k == 1
            n_chars -= 2
        end

        if i in row_sum
            print(row_buf, "━"^(n_chars-1))
            if ndims(X) == 2 && k in col_sum
                print(row_buf, "┿")
            else
                print(row_buf, "━")
            end
       end

        if k < length(A); print(io, sep); end
    end

    if i < size(X, 1)
        row_str = takebuf_string(row_buf)
        if length(row_str) > 0
            print(io, "\n ")
            print(io, row_str)
        end
    end
end
