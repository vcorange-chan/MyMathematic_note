### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 201aeec5-6b81-4fac-b6db-e5d76868b66a
using DelimitedFiles

# ╔═╡ a1e7f0a6-5fbd-4bd6-ac7b-06df6674309c
using CSV, DataFrames

# ╔═╡ 159d9ca9-eb68-4aff-9b2a-ce499091eaf6
using XLSX

# ╔═╡ 624e7a5c-832a-4879-9eef-e726e10591a8
using JLD, NPZ, MAT, RData

# ╔═╡ 58769a50-89ee-4b1b-ad90-ef0f8ab73444
md"""# 下载文件
`download`是Juia标准库函数， 根据URL下载文件， 并指定文件存储路径
"""

# ╔═╡ 75a39f70-fba0-11ed-251e-6100322cbb85
P = download("https://raw.githubusercontent.com/nassarhuda/easy_data/master/programming_languages.csv", "programming_languages.csv")

# ╔═╡ 035fa190-d67b-499a-a848-280c13e1406f
md"""
# 使用DelimitedFiles包读写数据文件：

+ 读： readdlm将文件内容读取为矩阵，赋值给变量。
+ 写： writedlm将矩阵内容写入文件，并规定元素分隔符。
"""

# ╔═╡ 6e0d0c46-b94c-4312-8bf7-00990e4e1e98
#=
readdlm(source,  文件源
    delim::AbstractChar,  元素分隔标记符号
    T::Type,  矩阵数据类型
    eol::AbstractChar; 
    header=false, 首行是否是题目
    skipstart=0, 
    skipblanks=true, 
    use_mmap, 
    quotes=true, 
    dims, 
    comments=false, 
    comment_char='#')
=#
p, H = readdlm("programming_languages.csv", ','; header=true)

# ╔═╡ 574de3eb-cf05-435b-a11f-6734310c82cd
p

# ╔═╡ 5078892c-b014-4dc5-94a4-464a50cac340
H

# ╔═╡ e56e853b-27db-4db4-b1c3-251740c8d504
writedlm("programminglanguages_dlm.txt", p, '-')

# ╔═╡ 8f179395-8dd2-468d-a98a-d7cde5fb03c9
md"""# 使用CSV和DataFrames包处理数据文件
+ 读： CSV.read
+ 使用first()或last()预览
+ 数据框索引
+ 数据框列名
+ 数据框描述 获取简明统计信息
+ 写： 将数据框写入文件
"""

# ╔═╡ 874fc30f-35c2-471d-a74d-35304d0d67ad
C = CSV.read("programming_languages.csv", DataFrame)

# ╔═╡ 5a7dd25d-43b9-4e69-960f-fcaf1e271d09
typeof(C)

# ╔═╡ fb1c69b3-a453-4ee4-b586-7af7f637a0e5
first(C, 6)

# ╔═╡ adfac338-d182-4cb9-b89b-de1a80cd3e66
last(C, 6)

# ╔═╡ 8e2a4f51-41be-4968-9844-5b5f3b2ac0df
md"数据框类型的变量支持索引"

# ╔═╡ 3ffbc1e3-7c4f-4abe-9fb7-308c3e6a2bfb
C[1:10, 1:2]

# ╔═╡ a22d5f3b-61d1-47de-9b29-2f364824efa0
C.year

# ╔═╡ 5e4644a7-16c0-4c65-9bf8-19d0f3f26949
md"获取数据框列名"

# ╔═╡ ad3a5b5b-2162-4f92-bb81-b17888e3f767
names(C)

# ╔═╡ 64e6c1da-37a9-452f-b305-3347a681e44e
md"简要描述数据框统计信息"

# ╔═╡ fc72d367-91e2-4de1-8645-2121d424690d
describe(C)

# ╔═╡ d0e17585-a7a9-4179-b862-36f18e9b8010
md"将矩阵转换为数据框后，再写入文件, 写入时自动检查数据类型"

# ╔═╡ 8ca24b66-836e-4def-a9f8-db710c258a47
CSV.write("programminglanguages_CSV.csv", DataFrame(p, :auto))

# ╔═╡ 86646f73-1bf3-4e7f-8e98-cef6cbfb8f52
md"""# 使用XLSL读写EXCEL文件
+ 读： readdata, 将EXCEL内容读取为矩阵, 注意指明(文件路径， 表格名称， 列范围)。
+ 改： 将代表xlsl数据矩阵的变量改为数据框， 改值、删行操作。
+ 合： 合并数据框
+ 写： 将数据写入xlsl文件
"""

# ╔═╡ 340486ae-9b87-44fb-9bb9-570bb7c9c4b1
T = XLSX.readdata("zillow_data_download_april2020.xlsx", #file name
    "Sale_counts_city", #sheet name
    "A1:F9"#cell range
    )

# ╔═╡ 7b077beb-e451-4191-b7e3-38b4e501a75a
D = DataFrame(T, :auto)

# ╔═╡ 4689c13d-6e89-4fc4-b103-a8b94e63f806
md"调整数据框， 重命名列名， 新列名是[第一行， 全部列]中的数据。注意列名是Symbol， 向量操作"

# ╔═╡ c1530da0-840d-4b18-8b3c-856a9092180f
rename!(D, Symbol.(Vector(D[1,:])))

# ╔═╡ 3faa9b68-3ddd-4a4f-8cb6-fe112c7d169b
md"用missing标记想要删除的行/列， dropmissing！删除之"

# ╔═╡ 185ce258-faa9-42c7-8f3f-d79fbc585964
D[1, 1] = missing

# ╔═╡ 8f4b7929-1084-4127-80c7-29d72f4fa343
D

# ╔═╡ a5a2e450-bf5e-4a8b-8e92-c119387de396
dropmissing!(D)

# ╔═╡ 207a0816-a66c-40c5-a6ac-5f8996b68b6e
D

# ╔═╡ 47fdc83c-2ac4-4d83-96c0-a528c0b83d79
size(D)

# ╔═╡ 32f741a2-33df-4d59-b01b-e949389e1989
md"合并数据框"

# ╔═╡ a891b0dd-d40e-481c-982e-dd04833cdebd
foods = ["apple", "cucumber", "tomato", "banana"]

# ╔═╡ 29969936-e849-434b-ba49-e0eccdb1fbd9
calories = [105,47,22,105]

# ╔═╡ e752b1ff-3dd7-4f7d-a15c-0b3bc5b978f9
prices = [0.85,1.6,0.8,0.6,]

# ╔═╡ 6a3eb834-a932-4d89-947b-25cb0e96a229
dataframe_calories = DataFrame(item=foods,calories=calories)

# ╔═╡ 44cebb63-5ef3-45ce-ad90-27997fcd94e5
dataframe_prices = DataFrame(item=foods,price=prices)

# ╔═╡ 92caf170-4f79-4479-9adb-959e87a12f5c
DF = innerjoin(dataframe_calories,dataframe_prices,on=:item)

# ╔═╡ 1025589a-70b8-4b9c-8125-b0d28fa37b85
md"第一、二列写入xlsx文件"

# ╔═╡ 66535bff-5b71-49f6-bbff-32cf9330e82e
XLSX.writetable("writefile_using_XLSX.xlsx",D[!, 1],D[!, 2])

# ╔═╡ 1a40f99b-1030-41a8-a406-c2b944d713e9
md""" # 导入数据
`jld`--julia data JLD 包\
`npy`--python data NPZ 包\
`mat`--matlab data MAT 包\
`rda`--R data RData 包\

+ 读： JLD。load; npzread; matread;
+ 写： save(路径，标识， jld数据); npzwrite(路径， 数据); matwrite(路径， 数据)
+ 查： findfirst, findall. keys, pairs.
"""

# ╔═╡ 56668419-9e47-4fe1-a6b0-12916405b18f
jld_data = JLD.load("mytempdata.jld")

# ╔═╡ 89eb6f1b-a7f4-4a0e-b60a-0bb9e8733900
# 保存路径， 识别名， 数据
save("mywrite.jld", "A", jld_data)

# ╔═╡ f3c6e3c6-3b64-4ccd-b3ab-c83ac0164952
npz_data = npzread("mytempdata.npz")

# ╔═╡ aa9979bd-a014-4660-b5a9-7656d68408a2
npzwrite("mywrite.npz", npz_data)

# ╔═╡ 1f97e94b-f4ba-4736-ac5b-f91e33ea3db6
Matlab_data = matread("mytempdata.mat")

# ╔═╡ 68a753f1-7cb0-44c7-8283-36a88bfe1414
matwrite("mywrite.mat",Matlab_data)

# ╔═╡ d9a46202-762b-483e-b34e-2ce175c81788
begin
function year_created(p,language::String)
    loc = findfirst(p[:,2] .== language)
    return p[loc,1]
end
year_created(p,"Julia")
end

# ╔═╡ a6b77f97-7faf-4cf7-ab27-c11256d2c94c
begin
function year_created_handle_error(P,language::String)
    loc = findfirst(P[:,2] .== language)
    !isnothing(loc) && return P[loc,1]
    error("Error: Language not found.")
end
year_created_handle_error(p,"W")
end

# ╔═╡ f3fdcb1f-d0bb-48fd-b569-ab87cd92c680
begin
	function how_many_per_year(P,year::Int64)
	    year_count = length(findall(P[:,1].==year))
	    return year_count
	end
	how_many_per_year(p,2011)
end

# ╔═╡ cce68c62-441a-4ba0-a55d-ed9405a7cc2c
typeof(C)

# ╔═╡ c4ff8330-5fb9-4637-98ae-3bc62b62de6b


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DelimitedFiles = "8bb1440f-4735-579b-a4ab-409b98df4dab"
JLD = "4138dd39-2aa7-5051-a626-17a0bb65d9c8"
MAT = "23992714-dd62-5051-b70f-ba57cb901cac"
NPZ = "15e1cf62-19b3-5cfa-8e77-841668bca605"
RData = "df47a6cb-8c03-5eed-afd8-b6050d6c41da"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[compat]
CSV = "~0.10.10"
DataFrames = "~1.5.0"
DelimitedFiles = "~1.9.1"
JLD = "~0.13.3"
MAT = "~0.10.4"
NPZ = "~0.4.3"
RData = "~1.0.0"
XLSX = "~0.9.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.0"
manifest_format = "2.0"
project_hash = "2283707061f2e5b03612f3fb7e0aab52579463ee"

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

[[deps.BufferedStreams]]
git-tree-sha1 = "bb065b14d7f941b8617bc323063dbe79f55d16ea"
uuid = "e1450e63-4bb3-523b-b2a4-4ffa8c0fd77d"
version = "1.1.0"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "ed28c86cbde3dc3f53cf76643c2e9bc11d56acc7"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.10"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "1568b28f91293458345dabba6a5ea3f183250a61"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.8"

    [deps.CategoricalArrays.extensions]
    CategoricalArraysJSONExt = "JSON"
    CategoricalArraysRecipesBaseExt = "RecipesBase"
    CategoricalArraysSentinelArraysExt = "SentinelArrays"
    CategoricalArraysStructTypesExt = "StructTypes"

    [deps.CategoricalArrays.weakdeps]
    JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SentinelArrays = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
    StructTypes = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

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

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExprTools]]
git-tree-sha1 = "c1d06d129da9f55715c6c212866f5b1bddc5fa00"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.9"

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

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

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

[[deps.MAT]]
deps = ["BufferedStreams", "CodecZlib", "HDF5", "SparseArrays"]
git-tree-sha1 = "6eff5740c8ab02c90065719579c7aa0eb40c9f69"
uuid = "23992714-dd62-5051-b70f-ba57cb901cac"
version = "0.10.4"

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

[[deps.Mocking]]
deps = ["Compat", "ExprTools"]
git-tree-sha1 = "782e258e80d68a73d8c916e55f8ced1de00c2cea"
uuid = "78c3b35d-d492-501b-9361-3d52fe80e533"
version = "0.7.6"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NPZ]]
deps = ["FileIO", "ZipFile"]
git-tree-sha1 = "60a8e272fe0c5079363b28b0953831e2dd7b7e6f"
uuid = "15e1cf62-19b3-5cfa-8e77-841668bca605"
version = "0.4.3"

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

[[deps.RData]]
deps = ["CategoricalArrays", "CodecZlib", "DataAPI", "DataFrames", "Dates", "FileIO", "Requires", "TimeZones", "Unicode"]
git-tree-sha1 = "9a6220c8f59c38ddf6217638042ae6788973f617"
uuid = "df47a6cb-8c03-5eed-afd8-b6050d6c41da"
version = "1.0.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

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

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

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

[[deps.TimeZones]]
deps = ["Dates", "Downloads", "InlineStrings", "LazyArtifacts", "Mocking", "Printf", "RecipesBase", "Scratch", "Unicode"]
git-tree-sha1 = "cdaa0c2a4449724aded839550eca7d7240bb6938"
uuid = "f269a46b-ccf7-5d73-abea-4c690281aa53"
version = "1.10.0"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

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
# ╟─58769a50-89ee-4b1b-ad90-ef0f8ab73444
# ╠═75a39f70-fba0-11ed-251e-6100322cbb85
# ╟─035fa190-d67b-499a-a848-280c13e1406f
# ╠═201aeec5-6b81-4fac-b6db-e5d76868b66a
# ╠═6e0d0c46-b94c-4312-8bf7-00990e4e1e98
# ╠═574de3eb-cf05-435b-a11f-6734310c82cd
# ╠═5078892c-b014-4dc5-94a4-464a50cac340
# ╠═e56e853b-27db-4db4-b1c3-251740c8d504
# ╟─8f179395-8dd2-468d-a98a-d7cde5fb03c9
# ╠═a1e7f0a6-5fbd-4bd6-ac7b-06df6674309c
# ╠═874fc30f-35c2-471d-a74d-35304d0d67ad
# ╠═5a7dd25d-43b9-4e69-960f-fcaf1e271d09
# ╠═fb1c69b3-a453-4ee4-b586-7af7f637a0e5
# ╠═adfac338-d182-4cb9-b89b-de1a80cd3e66
# ╟─8e2a4f51-41be-4968-9844-5b5f3b2ac0df
# ╠═3ffbc1e3-7c4f-4abe-9fb7-308c3e6a2bfb
# ╠═a22d5f3b-61d1-47de-9b29-2f364824efa0
# ╠═5e4644a7-16c0-4c65-9bf8-19d0f3f26949
# ╠═ad3a5b5b-2162-4f92-bb81-b17888e3f767
# ╠═64e6c1da-37a9-452f-b305-3347a681e44e
# ╠═fc72d367-91e2-4de1-8645-2121d424690d
# ╟─d0e17585-a7a9-4179-b862-36f18e9b8010
# ╠═8ca24b66-836e-4def-a9f8-db710c258a47
# ╟─86646f73-1bf3-4e7f-8e98-cef6cbfb8f52
# ╠═159d9ca9-eb68-4aff-9b2a-ce499091eaf6
# ╠═340486ae-9b87-44fb-9bb9-570bb7c9c4b1
# ╠═7b077beb-e451-4191-b7e3-38b4e501a75a
# ╠═4689c13d-6e89-4fc4-b103-a8b94e63f806
# ╠═c1530da0-840d-4b18-8b3c-856a9092180f
# ╠═3faa9b68-3ddd-4a4f-8cb6-fe112c7d169b
# ╠═185ce258-faa9-42c7-8f3f-d79fbc585964
# ╠═8f4b7929-1084-4127-80c7-29d72f4fa343
# ╠═a5a2e450-bf5e-4a8b-8e92-c119387de396
# ╠═207a0816-a66c-40c5-a6ac-5f8996b68b6e
# ╠═47fdc83c-2ac4-4d83-96c0-a528c0b83d79
# ╠═32f741a2-33df-4d59-b01b-e949389e1989
# ╠═a891b0dd-d40e-481c-982e-dd04833cdebd
# ╠═29969936-e849-434b-ba49-e0eccdb1fbd9
# ╠═e752b1ff-3dd7-4f7d-a15c-0b3bc5b978f9
# ╠═6a3eb834-a932-4d89-947b-25cb0e96a229
# ╠═44cebb63-5ef3-45ce-ad90-27997fcd94e5
# ╠═92caf170-4f79-4479-9adb-959e87a12f5c
# ╠═1025589a-70b8-4b9c-8125-b0d28fa37b85
# ╠═66535bff-5b71-49f6-bbff-32cf9330e82e
# ╠═1a40f99b-1030-41a8-a406-c2b944d713e9
# ╠═624e7a5c-832a-4879-9eef-e726e10591a8
# ╠═56668419-9e47-4fe1-a6b0-12916405b18f
# ╠═89eb6f1b-a7f4-4a0e-b60a-0bb9e8733900
# ╠═f3c6e3c6-3b64-4ccd-b3ab-c83ac0164952
# ╠═aa9979bd-a014-4660-b5a9-7656d68408a2
# ╠═1f97e94b-f4ba-4736-ac5b-f91e33ea3db6
# ╠═68a753f1-7cb0-44c7-8283-36a88bfe1414
# ╠═d9a46202-762b-483e-b34e-2ce175c81788
# ╠═a6b77f97-7faf-4cf7-ab27-c11256d2c94c
# ╠═f3fdcb1f-d0bb-48fd-b569-ab87cd92c680
# ╠═cce68c62-441a-4ba0-a55d-ed9405a7cc2c
# ╠═c4ff8330-5fb9-4637-98ae-3bc62b62de6b
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
