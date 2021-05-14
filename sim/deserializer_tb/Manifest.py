action = "simulation"
sim_tool = "modelsim"
sim_top = "deserializer_tb"

sim_post_cmd = "vsim -do ../vsim.do -c deserializer_tb"

modules = {
  "local" : [ "../../test/" ],
}
