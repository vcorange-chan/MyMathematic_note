### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ fd794940-fd62-11ed-1cb3-c71afe5b11b6
using DataFrames,XLSX 

# ╔═╡ 0dc6f6a7-1384-42e7-aaa8-e43e93f34f0a
using Statistics

# ╔═╡ 46f13e84-ebcc-4fb3-a80a-eaffeb0fce34
using JLD

# ╔═╡ 8145b82a-c0e1-4f43-981a-da14d1dc5441
md"# Import Data"

# ╔═╡ 1dac56a9-b760-4119-9279-3ffdbd19aa6a
md"""## Import the data of residential quarter
Import data of estates from table3.xlsx; sheet="各区主要小区数据"; range="A1:H1410"
"""

# ╔═╡ 832c5fcd-b503-4a7e-afe8-77ff0a753139
T3 = XLSX.readdata("data/table3.xlsx", "各区主要小区数据", "A1:H1410")

# ╔═╡ 620946c7-64d3-4a7e-9667-fbe09eca8bce
md"Convert T3 Matrix to DataFrame"

# ╔═╡ bd639c16-0e16-452b-a4e0-c0977c96cdba
DT3 = DataFrame(T3, :auto)

# ╔═╡ 39cf59a6-4f7a-4f05-add6-450b9fb8855f
md"Change the column name to the correct name, not x1 x2"

# ╔═╡ 501fc8ed-6613-4a84-828f-8322ef7f4786
rename!(DT3, Symbol.(Vector(DT3[1,:])))

# ╔═╡ 50d3900f-501a-42d5-8057-a169374f3d42
md"Collate data and drop data of inconsistent types."

# ╔═╡ 7848726f-d805-41ac-a43b-c2a5407a577b
begin
	DT3[1,1] = missing
	dropmissing!(DT3)
end

# ╔═╡ b89789fc-ec8a-4d86-8836-cac0438fbbe2
md"""
Now remember DT3 is what we need dataframe representing the residential quarters.
"""

# ╔═╡ 1d8f70fb-2f98-43c7-b56e-0b7cae2bd2ea
md"""## Import the data of crossing
Import data of estates from table3.xlsx; sheet="交通路口节点数据"; range="A1:C9933"
"""

# ╔═╡ e3bc8102-1aba-4194-9c14-027b996e6cb8
T1 = XLSX.readdata("data/table3.xlsx", "交通路口节点数据", "A1:C9933")

# ╔═╡ e14f2af1-6b9b-4be6-abc6-76fb5ed4c3e3
DT1 = DataFrame(T1, :auto)

# ╔═╡ 8204cee1-94a0-45ee-992c-275e0f4d385a
begin
	rename!(DT1, Symbol.(Vector(DT1[1,:])))
	DT1[1,1] = missing
	dropmissing!(DT1)
end

# ╔═╡ 7a44f956-c5b8-436a-b78d-f4f497843fa9
md"Now remember DT1 is what we need dataframe representing the crossing data."

# ╔═╡ 4ef3ca5d-a99c-411e-b441-b8d8e574c01e
md"Preview the first 5 row of the data"

# ╔═╡ 019b7e2f-ca06-4a52-9b6b-5dd842798cda
first(DT1, 5)

# ╔═╡ e02f685e-311c-4161-9b0f-756473490220
first(DT3, 5)

# ╔═╡ 6c892f50-2308-4974-bb85-56822d7c4d00
md"# Create Points Set"

# ╔═╡ 2442d354-f252-49cd-b7fb-a4a4c04b0ee2
md"""
+ J: set of all candidate locations, J[j] = (x, y)
+ I: set of demand points, I[i] = (x, y, w)
"""

# ╔═╡ 1a5a3104-27d7-4ea5-9607-d66b6618a09f
begin
	J = Dict()
	for row in eachrow(DT1)
	    id = row.节点编号
	    x = row.路口横坐标
	    y = row.路口纵坐标
	    J[id] = (x, y)
	end
end

# ╔═╡ 4405d677-3af3-4c8f-9480-4da6da3ce1d7
J

# ╔═╡ e2a2a97b-58cb-4458-a842-353ab14e91ed
begin
	I = Dict()
	for row in eachrow(DT3)
	    id = row.小区编号
	    x = row.小区横坐标
	    y = row.小区纵坐标
		w = row."小区人口数（人）"
	    I[id] = (x, y, w)
	end
end

# ╔═╡ 12a98535-c051-49aa-afde-1e8736725d11
I

# ╔═╡ 315c7a38-0110-4f6d-b5e3-7911cd9a326d
I[1][3]

# ╔═╡ 4df2ecb0-5173-46d9-8595-4595c3b546b1
begin
	w = zeros(1,1409)
	for i in 1:length(I)
		w[i] = I[i][3]
	end
end

# ╔═╡ 95aa419d-e0c4-4010-ad90-4bf832823c2e
w

# ╔═╡ 9171de89-e00e-45ed-b028-3203611ce291
sum(w[i] for i in 1:length(I))

# ╔═╡ a372c39f-3625-4b50-96f2-659eea68f45a
first(J, 5)

# ╔═╡ eaec493c-25dc-4b75-895c-c8f60a853ffc
first(I, 5)

# ╔═╡ 2f5dba06-5398-4397-8282-3d9c2209df4b
md"""# Create D and S
+ D_i distance standard for demand point i, Here we set const D = 3
+ S is the number of available servers
"""

# ╔═╡ 3c678b9b-99a6-4ce8-b4c0-639404ea939e
begin
	const D = 3
	const S = 1556
end

# ╔═╡ 3530d89a-13c1-4c2a-8dd8-26f8cc20439b
md"""# Create distance matrix between i and j
"""

# ╔═╡ 0fbabfa5-a8b0-497c-8f9f-8bf57c20add7
function distance(x1, y1, x2, y2)
	return (x1-x2)^2+(y1-y2)^2
end

# ╔═╡ 3aabd97b-9cd8-4ad4-bb51-92971845d8d1
d = zeros(length(I), length(J))

# ╔═╡ 942e46d5-58e6-4b85-90f6-5c92d450985e
for i in 1:length(I)
	for j in 1:length(J)
		d[i, j] = distance(I[i][1], I[i][2], J[j][1], J[j][2])
	end
end

# ╔═╡ e5a82731-b4c3-41e1-82ac-59b18a864856
d

# ╔═╡ 85cf71a0-534e-4381-935a-d4e0eaff2121
md"The minimum distance value and i，j"

# ╔═╡ f47f7809-8f85-4675-ab3e-6e6413886048
min_d = minimum(d)

# ╔═╡ 37df08d2-5193-40d5-9b62-b89839aaba85
findall(x-> x == min_d, d)

# ╔═╡ 23e951ed-94d1-4f03-8725-35ca7b413694
I[465]

# ╔═╡ b142a4f3-36a0-4076-bd40-a937cefddd6f
J[250]

# ╔═╡ ea02499a-ad7d-413e-a9e1-b6ba58c8b535
md"The maximum distance value and its point"

# ╔═╡ 6890440c-7196-4f1e-a5bd-ccf9a6893428
max_d = maximum(d)

# ╔═╡ 67967136-9cda-4682-9095-46badec5468b
findall(x-> x == max_d, d)

# ╔═╡ 5e926425-a673-4a69-a92a-a397d8431f41
begin
@show I[1056]
@show J[1627]
end

# ╔═╡ f44d7d08-c2d9-4f38-8e1a-e36dc9faf96a
avgd = mean(d)

# ╔═╡ 08936dd2-e005-4690-824e-404a067755bc
count(x -> x < 0.2, d)

# ╔═╡ 6ece9d65-3c42-4e6f-88fe-e512a78890d2
median(d)

# ╔═╡ ac8d1d4e-87c8-4889-9112-8905e95d22ce
md"500m/unit"

# ╔═╡ 6e4e94ff-dc44-43ec-90b6-1dac10d70b2c
count(x -> x < D^2, d)

# ╔═╡ 37c40a2a-a901-4fe8-a9b3-34981bd61975
md"# Create i-j cover couple"

# ╔═╡ 0c5fcaf2-bc99-4ed0-96ee-f1984d26e1fd
N = copy(d)

# ╔═╡ d95e720d-ebb4-4558-99e6-457aab220266
Nd = copy(d)

# ╔═╡ 1a2e9fb9-fca7-42e1-b09b-0e32216522f1
for i in 1:length(I)
	for j in 1:length(J)
		if d[i, j] > D^2 # r = 3*500m
			N[i, j] = 0
			Nd[i, j] = 0
		else
			N[i, j] = 1
		end
	end
end

# ╔═╡ 957d24e7-dcab-452c-938c-3f8373a41021
N

# ╔═╡ 392a0bea-f0f9-4335-be70-72d2bb386abc
Nd

# ╔═╡ 7c8d940e-d650-4765-9863-e7157874ed19
count(x -> x == 1, N)

# ╔═╡ bb41d871-d05a-45d5-a158-56e379420e37
count(x -> x > 0, Nd)

# ╔═╡ e6fdda9f-5a55-4c79-9e8f-9e4d68d1c0b2
Nd_col = [sum(col) for col in eachcol(Nd)]

# ╔═╡ b7f151ea-7cf5-4b9c-ba47-80c55f2919b9
size(Nd_col)

# ╔═╡ 138858a3-e6c0-4d53-a433-b9b900a9ed23
count(x -> x != 0, Nd_col)

# ╔═╡ 0da159ad-c84a-4035-a9c1-81837aeb7ad6
m = ones(1, length(J))

# ╔═╡ b93a5a89-35e4-463b-9f3d-086909b9314b
md"# Save data matrix"

# ╔═╡ d77ffd45-966f-4567-929b-4d606e9a6b4f
# 约束条件的系数矩阵， 标识有效服务组合
save("data/N.jld", "A", N)

# ╔═╡ 0759ed92-bc15-4afa-b8fd-6fa35596cfc1
# 人口数权重
save("data/w.jld", "C", w)

# ╔═╡ 181a7c29-5b49-4ea7-bff3-6083a3c19739
# 1向量，约束设备数量不超过总数
save("data/m.jld", "A+1", m)

# ╔═╡ 209332e7-5c8b-4118-8932-4c74e1d05c7e
# 小区数据 坐标，人口
save("data/I.jld", "I", I)

# ╔═╡ 9181fe9e-a5b3-4f6e-8385-e16db0fd9a1c
# 路口数据 坐标
save("data/J.jld", "J", J)

# ╔═╡ b5d0af84-18d7-4862-a4a9-e548f076e738
# 距离矩阵， 小区i 到 路口 j 的距离
save("data/d.jld", "d_ij", d)

# ╔═╡ f52a3c8a-ec6e-4d95-9f24-bbd911e9ce32
# 有效服务距离的列， 体现每个设备的服务总距离
save("data/Nd_col.jld", "col", Nd_col)

# ╔═╡ 305200cb-7a2d-4214-b0ac-855f42fc227f
length(I)

# ╔═╡ dc90bf86-b8e3-4d51-a9d4-92ef0f265b42
length(J)

# ╔═╡ 635e71dd-fcf0-4db0-8384-9db2a80e5db9
md"""
x = [1:9932] \
y = ones[1:9932]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
JLD = "4138dd39-2aa7-5051-a626-17a0bb65d9c8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[compat]
DataFrames = "~1.5.0"
JLD = "~0.13.3"
XLSX = "~0.9.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.0"
manifest_format = "2.0"
project_hash = "40ab7c26bedaa51c8066467e42f42c221530e5ae"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Blosc]]
deps = ["Blosc_jll"]
git-tree-sha1 = "310b77648d38c223d947ff3f50f511d08690b8d5"
uuid = "a74b3585-a348-5f62-a45c-50e91977d574"
version = "0.7.3"

[[deps.Blosc_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Lz4_jll", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "e94024822c0a5b14989abbdba57820ad5b177b95"
uuid = "0b7ba130-8d10-5ba8-a3d6-c5182647fed9"
version = "1.21.2+0"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "7a60c856b9fa189eb34f5f8a6f6b5529b7942957"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.2+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "aa51303df86f8626a962fccb878430cdb0a97eee"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.5.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "0fa3b52a04a4e210aeb1626def9c90df3ae65268"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.1.0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "299dc33549f68299137e51e6d49a13b5b1da9673"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.H5Zblosc]]
deps = ["Blosc", "HDF5"]
git-tree-sha1 = "d3966da25e48c05c31cd9786fd201627877612a2"
uuid = "c8ec2601-a99c-407f-b158-e79c03c2f5f7"
version = "0.1.1"

[[deps.HDF5]]
deps = ["Compat", "HDF5_jll", "Libdl", "Mmap", "Random", "Requires", "UUIDs"]
git-tree-sha1 = "c73fdc3d9da7700691848b78c61841274076932a"
uuid = "f67ccb44-e63f-5c2f-98bd-6dc0ccc4ba2f"
version = "0.16.15"

[[deps.HDF5_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "LazyArtifacts", "LibCURL_jll", "Libdl", "MPICH_jll", "MPIPreferences", "MPItrampoline_jll", "MicrosoftMPI_jll", "OpenMPI_jll", "OpenSSL_jll", "TOML", "Zlib_jll", "libaec_jll"]
git-tree-sha1 = "3b20c3ce9c14aedd0adca2bc8c882927844bd53d"
uuid = "0234f1f7-429e-5d53-9886-15a909be8d59"
version = "1.14.0+0"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLD]]
deps = ["Compat", "FileIO", "H5Zblosc", "HDF5", "Printf"]
git-tree-sha1 = "ec6afa4fd3402e4dd5b15b3e5dd2f7dd52043ce8"
uuid = "4138dd39-2aa7-5051-a626-17a0bb65d9c8"
version = "0.13.3"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f689897ccbe049adb19a065c495e75f372ecd42b"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "15.0.4+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Lz4_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5d494bc6e85c4c9b626ee0cab05daa4085486ab1"
uuid = "5ced341a-0733-55b8-9ab6-a4889d929147"
version = "1.9.3+0"

[[deps.MPICH_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "MPIPreferences", "TOML"]
git-tree-sha1 = "d790fbd913f85e8865c55bf4725aff197c5155c8"
uuid = "7cb0a576-ebde-5e09-9194-50597f1243b4"
version = "4.1.1+1"

[[deps.MPIPreferences]]
deps = ["Libdl", "Preferences"]
git-tree-sha1 = "71f937129731a29eabe6969db2c90368a4408933"
uuid = "3da0fdf6-3ccc-4f1b-acd9-58baa6c99267"
version = "0.1.7"

[[deps.MPItrampoline_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "MPIPreferences", "TOML"]
git-tree-sha1 = "b3dcf8e1c610a10458df3c62038c8cc3a4d6291d"
uuid = "f1f71cc9-e9ae-5b93-9b94-4fe0e1ad3748"
version = "5.3.0+0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.MicrosoftMPI_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "a8027af3d1743b3bfae34e54872359fdebb31422"
uuid = "9237b28f-5490-5468-be7b-bb81f5f5e6cf"
version = "10.1.3+4"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenMPI_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "MPIPreferences", "TOML"]
git-tree-sha1 = "f3080f4212a8ba2ceb10a34b938601b862094314"
uuid = "fe0851c0-eecd-5654-98d4-656369965a5c"
version = "4.1.5+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6cc6366a14dbe47e5fc8f3cbe2816b1185ef5fc4"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.8+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "a5aef8d4a6e8d81f171b2bd4be5265b01384c74c"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.10"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.0"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "259e206946c293698122f63e2b513a7c99a244e8"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "213579618ec1f42dea7dd637a42785a608b1ea9c"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.4"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "77d3c4726515dca71f6d80fbb5e251088defe305"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.18"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.XLSX]]
deps = ["Artifacts", "Dates", "EzXML", "Printf", "Tables", "ZipFile"]
git-tree-sha1 = "d6af50e2e15d32aff416b7e219885976dc3d870f"
uuid = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"
version = "0.9.0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[deps.ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "f492b7fe1698e623024e873244f10d89c95c340a"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.10.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.libaec_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eddd19a8dea6b139ea97bdc8a0e2667d4b661720"
uuid = "477f73a3-ac25-53e9-8cc3-50b2fa2566f0"
version = "1.0.6+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.7.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═fd794940-fd62-11ed-1cb3-c71afe5b11b6
# ╟─8145b82a-c0e1-4f43-981a-da14d1dc5441
# ╟─1dac56a9-b760-4119-9279-3ffdbd19aa6a
# ╠═832c5fcd-b503-4a7e-afe8-77ff0a753139
# ╟─620946c7-64d3-4a7e-9667-fbe09eca8bce
# ╠═bd639c16-0e16-452b-a4e0-c0977c96cdba
# ╟─39cf59a6-4f7a-4f05-add6-450b9fb8855f
# ╠═501fc8ed-6613-4a84-828f-8322ef7f4786
# ╟─50d3900f-501a-42d5-8057-a169374f3d42
# ╠═7848726f-d805-41ac-a43b-c2a5407a577b
# ╟─b89789fc-ec8a-4d86-8836-cac0438fbbe2
# ╟─1d8f70fb-2f98-43c7-b56e-0b7cae2bd2ea
# ╠═e3bc8102-1aba-4194-9c14-027b996e6cb8
# ╠═e14f2af1-6b9b-4be6-abc6-76fb5ed4c3e3
# ╠═8204cee1-94a0-45ee-992c-275e0f4d385a
# ╟─7a44f956-c5b8-436a-b78d-f4f497843fa9
# ╟─4ef3ca5d-a99c-411e-b441-b8d8e574c01e
# ╠═019b7e2f-ca06-4a52-9b6b-5dd842798cda
# ╠═e02f685e-311c-4161-9b0f-756473490220
# ╟─6c892f50-2308-4974-bb85-56822d7c4d00
# ╟─2442d354-f252-49cd-b7fb-a4a4c04b0ee2
# ╠═1a5a3104-27d7-4ea5-9607-d66b6618a09f
# ╠═4405d677-3af3-4c8f-9480-4da6da3ce1d7
# ╠═e2a2a97b-58cb-4458-a842-353ab14e91ed
# ╠═12a98535-c051-49aa-afde-1e8736725d11
# ╠═315c7a38-0110-4f6d-b5e3-7911cd9a326d
# ╠═4df2ecb0-5173-46d9-8595-4595c3b546b1
# ╠═95aa419d-e0c4-4010-ad90-4bf832823c2e
# ╠═9171de89-e00e-45ed-b028-3203611ce291
# ╠═a372c39f-3625-4b50-96f2-659eea68f45a
# ╠═eaec493c-25dc-4b75-895c-c8f60a853ffc
# ╠═2f5dba06-5398-4397-8282-3d9c2209df4b
# ╠═3c678b9b-99a6-4ce8-b4c0-639404ea939e
# ╟─3530d89a-13c1-4c2a-8dd8-26f8cc20439b
# ╠═0fbabfa5-a8b0-497c-8f9f-8bf57c20add7
# ╠═3aabd97b-9cd8-4ad4-bb51-92971845d8d1
# ╠═942e46d5-58e6-4b85-90f6-5c92d450985e
# ╠═e5a82731-b4c3-41e1-82ac-59b18a864856
# ╟─85cf71a0-534e-4381-935a-d4e0eaff2121
# ╠═f47f7809-8f85-4675-ab3e-6e6413886048
# ╠═37df08d2-5193-40d5-9b62-b89839aaba85
# ╠═23e951ed-94d1-4f03-8725-35ca7b413694
# ╠═b142a4f3-36a0-4076-bd40-a937cefddd6f
# ╟─ea02499a-ad7d-413e-a9e1-b6ba58c8b535
# ╠═6890440c-7196-4f1e-a5bd-ccf9a6893428
# ╠═67967136-9cda-4682-9095-46badec5468b
# ╠═5e926425-a673-4a69-a92a-a397d8431f41
# ╠═0dc6f6a7-1384-42e7-aaa8-e43e93f34f0a
# ╠═f44d7d08-c2d9-4f38-8e1a-e36dc9faf96a
# ╠═08936dd2-e005-4690-824e-404a067755bc
# ╠═6ece9d65-3c42-4e6f-88fe-e512a78890d2
# ╟─ac8d1d4e-87c8-4889-9112-8905e95d22ce
# ╠═6e4e94ff-dc44-43ec-90b6-1dac10d70b2c
# ╟─37c40a2a-a901-4fe8-a9b3-34981bd61975
# ╠═0c5fcaf2-bc99-4ed0-96ee-f1984d26e1fd
# ╠═d95e720d-ebb4-4558-99e6-457aab220266
# ╠═1a2e9fb9-fca7-42e1-b09b-0e32216522f1
# ╠═957d24e7-dcab-452c-938c-3f8373a41021
# ╠═392a0bea-f0f9-4335-be70-72d2bb386abc
# ╠═7c8d940e-d650-4765-9863-e7157874ed19
# ╠═bb41d871-d05a-45d5-a158-56e379420e37
# ╠═e6fdda9f-5a55-4c79-9e8f-9e4d68d1c0b2
# ╠═b7f151ea-7cf5-4b9c-ba47-80c55f2919b9
# ╠═138858a3-e6c0-4d53-a433-b9b900a9ed23
# ╠═0da159ad-c84a-4035-a9c1-81837aeb7ad6
# ╠═b93a5a89-35e4-463b-9f3d-086909b9314b
# ╠═46f13e84-ebcc-4fb3-a80a-eaffeb0fce34
# ╠═d77ffd45-966f-4567-929b-4d606e9a6b4f
# ╠═0759ed92-bc15-4afa-b8fd-6fa35596cfc1
# ╠═181a7c29-5b49-4ea7-bff3-6083a3c19739
# ╠═209332e7-5c8b-4118-8932-4c74e1d05c7e
# ╠═9181fe9e-a5b3-4f6e-8385-e16db0fd9a1c
# ╠═b5d0af84-18d7-4862-a4a9-e548f076e738
# ╠═f52a3c8a-ec6e-4d95-9f24-bbd911e9ce32
# ╠═305200cb-7a2d-4214-b0ac-855f42fc227f
# ╠═dc90bf86-b8e3-4d51-a9d4-92ef0f265b42
# ╠═635e71dd-fcf0-4db0-8384-9db2a80e5db9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
