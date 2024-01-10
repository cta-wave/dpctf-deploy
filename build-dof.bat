@echo off

set reload_dof=false

for %%i in (%*) do (
  if "%%i" == "--reload-dof" (
    set reload_dof=true
  )
)

set args=

if %reload_dof% == true (
  set args=%args% --build-arg dof-rev="%date: =%" 
)

docker build %args% --file Dockerfile.dof -t dpctf-dof:latest .
