# Hook 6 — package-version guard. PostToolUse, matcher Edit|Write|MultiEdit.
# Warns rather than blocks: PostToolUse runs after the write, so there is nothing left to stop.
H=cpm-guard.sh
P="$WORK/proj"; mkdir -p "$P"

cat > "$P/Attr.csproj" <<'XML'
<Project Sdk="Microsoft.NET.Sdk">
  <ItemGroup>
    <PackageReference Include="Serilog" Version="4.2.0" />
  </ItemGroup>
</Project>
XML
# Visual Studio writes multi-line elements as a matter of course. A line-oriented grep sees
# neither line as a violation and reports nothing — the silent pass, again.
cat > "$P/Multi.csproj" <<'XML'
<Project Sdk="Microsoft.NET.Sdk">
  <ItemGroup>
    <PackageReference Include="Serilog"
                      Version="4.2.0" />
  </ItemGroup>
</Project>
XML
# The other spelling of a pinned version: a child element rather than an attribute.
cat > "$P/Child.csproj" <<'XML'
<Project Sdk="Microsoft.NET.Sdk">
  <ItemGroup>
    <PackageReference Include="Dapper">
      <Version>2.1.0</Version>
    </PackageReference>
  </ItemGroup>
</Project>
XML
cat > "$P/Clean.csproj" <<'XML'
<Project Sdk="Microsoft.NET.Sdk">
  <ItemGroup>
    <PackageReference Include="Serilog" />
    <PackageReference Include="xunit.v3" PrivateAssets="all" />
  </ItemGroup>
</Project>
XML

check $H warn   'Version attribute'       "$(payload_file Edit "$P/Attr.csproj")"
check $H warn   'multi-line element'      "$(payload_file Edit "$P/Multi.csproj")"
check $H warn   '<Version> child'         "$(payload_file Edit "$P/Child.csproj")"
check $H silent 'no version pinned'       "$(payload_file Edit "$P/Clean.csproj")"
check $H silent 'not a project file'      "$(payload_file Edit "$P/Attr.csproj.bak")"
check $H silent 'a .cs file'              "$(payload_file Edit /repo/src/Program.cs)"
check $H silent 'a project that is gone'  "$(payload_file Edit "$P/Missing.csproj")"
check $H silent 'empty payload'           ''
