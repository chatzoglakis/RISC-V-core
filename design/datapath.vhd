library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity datapath is
    port(
        clk: in STD_LOGIC;
        rst_btn: in STD_LOGIC
    );
end datapath;

architecture rtl of datapath is

    signal data_ram_we: STD_LOGIC_VECTOR(3 downto 0);
    signal inst_data_in: STD_LOGIC_VECTOR(31 downto 0);


    signal pc_in: STD_LOGIC_VECTOR(31 downto 0);
    signal pc_out: STD_LOGIC_VECTOR(31 downto 0);
    signal next_pc: STD_LOGIC_VECTOR(31 downto 0);

    signal take_branch: STD_LOGIC;

    signal reg_out1: STD_LOGIC_VECTOR(31 downto 0);
    signal reg_out2: STD_LOGIC_VECTOR(31 downto 0);

    signal immediate: STD_LOGIC_VECTOR(31 downto 0);

    signal reg_data_in: STD_LOGIC_VECTOR(31 downto 0);

    signal instruction    : std_logic_vector (31 downto 0);
    signal imm_sel        : std_logic_vector (2 downto 0);
    signal ALU_src1        : std_logic;
    signal ALU_src2        : std_logic;
    signal branch_add_src : std_logic;
    signal branch_en      : std_logic;
    signal ALU_op         : std_logic_vector (2 downto 0);
    signal sub_arShift    : std_logic;
    signal jump           : std_logic;
    signal reg_data_src   : std_logic_vector (1 downto 0);
    signal reg_we         : std_logic;
    signal is_store_inst  : std_logic;

    signal alu_a: STD_LOGIC_VECTOR(31 downto 0);
    signal alu_b: STD_LOGIC_VECTOR(31 downto 0);
    signal alu_shamt: STD_LOGIC_VECTOR(4 downto 0);
    signal alu_out: STD_LOGIC_VECTOR(31 downto 0);

    signal data_mem_out: STD_LOGIC_VECTOR(31 downto 0);
    signal mem_writeback_data: STD_LOGIC_VECTOR(31 downto 0);
    signal ram_data_in: STD_LOGIC_VECTOR(31 downto 0);

begin

    pc_proc: process(clk)
    begin
        if rising_edge(clk) then
            if rst_btn = '1' then
                pc_out <= (others => '0');
            else
                pc_out <= pc_in;
            end if;
        end if;

        next_pc <= STD_LOGIC_VECTOR(unsigned(pc_out) + 4);

        if jump = '1' or take_branch = '1' then
                if branch_add_src = '0' then --JALR
                    pc_in <= STD_LOGIC_VECTOR(unsigned(immediate) + unsigned(reg_out1))(31 downto 1) & '0'; 
                else --BRANCH/JAL
                    pc_in <= STD_LOGIC_VECTOR(unsigned(immediate) + unsigned(pc_out));
                end if;
        else
                pc_in <= next_pc;
        end if;
    end process;

    instruction_ram: entity work.ram
     generic map(
        ADDRESS_WIDTH => 12
    )
     port map(
        clk => clk,
        we => "0000",
        address => pc_out(13 downto 2),
        data_in => inst_data_in,
        data_out => instruction
    );

    --Determines register file input
    reg_input_proc: process(all)
    begin
        case reg_data_src is
            when "00" => reg_data_in <= alu_out; --ALU output
            when "01" => reg_data_in <= mem_writeback_data; --Data Memory output
            when "10" => reg_data_in <= immediate; --immediate
            when others => reg_data_in <= next_pc; --PC
        end case;
    end process;

    reg_file: entity work.reg_file
     generic map(
        ADDRESS_WIDTH => 5,
        DATA_WIDTH => 32
    )
     port map(
        clk => clk,
        rs1 => instruction(19 downto 15),
        rs2 => instruction(24 downto 20),
        rd => instruction(11 downto 7),
        we => reg_we,
        data_in => reg_data_in,
        reg_out1 => reg_out1,
        reg_out2 => reg_out2
    );

    control_unit: entity work.control_unit
     port map(
        instruction => instruction,
        imm_sel => imm_sel,
        ALU_src1 => ALU_src1,
        ALU_src2 => ALU_src2,
        branch_add_src => branch_add_src,
        branch_en => branch_en,
        ALU_op => ALU_op,
        sub_arShift => sub_arShift,
        jump => jump,
        reg_data_src => reg_data_src,
        reg_we => reg_we,
        is_store_inst => is_store_inst
    );

    imm_gen_unit: entity work.imm_gen_unit
     port map(
        instruction => instruction,
        imm_sel => imm_sel,
        immediate => immediate
    );

    alu_a <= reg_out1 when ALU_src1 = '0' else pc_out;
    alu_b <= reg_out2 when ALU_src2 = '0' else immediate;
    alu_shamt <= reg_out2(4 downto 0) when ALU_src2 = '0' else immediate(4 downto 0);

    alu: entity work.alu
     port map(
        a => alu_a,
        b => alu_b,
        op => ALU_op,
        sub_arShift => sub_arShift,
        shamt => alu_shamt,
        result => alu_out
    );

    store_alignment_unit: entity work.store_alignment_unit
     port map(
        funct3 => instruction(14 downto 12),
        alu_out => alu_out,
        reg_out2 => reg_out2,
        is_store_inst => is_store_inst,
        ram_data_in => ram_data_in,
        ram_we => data_ram_we
    );

    data_ram: entity work.ram
     generic map(
        ADDRESS_WIDTH => 12
    )
     port map(
        clk => clk,
        we => data_ram_we,
        address => alu_out(13 downto 2),
        data_in => ram_data_in,
        data_out => data_mem_out
    );

    data_loading_unit: entity work.data_loading_unit
     port map(
        data_mem_out => data_mem_out,
        alu_out => alu_out,
        funct3 => instruction(14 downto 12),
        mem_writeback_data => mem_writeback_data
    );

    branch_condition_unit: entity work.branch_condition_unit
     port map(
        funct3 => instruction(14 downto 12),
        ALUout => alu_out,
        en => branch_en,
        take_branch => take_branch
    );

end rtl;
