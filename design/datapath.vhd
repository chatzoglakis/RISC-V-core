library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
    port(
        clk: in STD_LOGIC;
        rst_btn: in STD_LOGIC;
        prog_mode: in STD_LOGIC;
        rx: in STD_LOGIC;
        raw_btn_input: in STD_LOGIC_VECTOR(3 downto 0);
        hsync, vsync: out STD_LOGIC;
        r,g,b: out STD_LOGIC_VECTOR(3 downto 0)
    );
end datapath;

architecture rtl of datapath is

    constant FRAMEBUFFER_CONTROL_ADDRESS: STD_LOGIC_VECTOR(31 downto 0) := x"80000000";
    constant BUTTON_REG_ADDRESS: STD_LOGIC_VECTOR(31 downto 0) := x"80000004";
    constant VGA_STATUS_ADDRESS: STD_LOGIC_VECTOR(31 downto 0) := x"80000008"; --Bit 0 of address = swap_pending (1 = Busy drawing, 0 = Ready to switch buffers)

    type IF_ID is record
        pc: STD_LOGIC_VECTOR(31 downto 0);
        instruction: STD_LOGIC_VECTOR(31 downto 0);
    end record;

    type ID_EX is record
        pc: STD_LOGIC_VECTOR(31 downto 0);
        rs1: STD_LOGIC_VECTOR(4 downto 0);
        rs2: STD_LOGIC_VECTOR(4 downto 0);
        rd: STD_LOGIC_VECTOR(4 downto 0);
        reg_out1: STD_LOGIC_VECTOR(31 downto 0);
        reg_out2: STD_LOGIC_VECTOR(31 downto 0);
        immediate: STD_LOGIC_VECTOR(31 downto 0);
        ALU_src1       : std_logic;
        ALU_src2       : std_logic;
        branch_add_src : std_logic;
        branch_en      : std_logic;
        ALU_op         : std_logic_vector (2 downto 0);
        sub_arShift    : std_logic;
        jump           : std_logic;
        reg_data_src   : std_logic_vector (1 downto 0);
        reg_we         : std_logic;
        is_store_inst  : std_logic;
        funct3: STD_LOGIC_VECTOR(2 downto 0);
        opcode: STD_LOGIC_VECTOR(4 downto 0);
    end record;

    type EX_MEM is record
        pc: STD_LOGIC_VECTOR(31 downto 0);
        reg_out2: STD_LOGIC_VECTOR(31 downto 0);
        immediate: STD_LOGIC_VECTOR(31 downto 0);
        rd: STD_LOGIC_VECTOR(4 downto 0);
        reg_data_src: STD_LOGIC_VECTOR(1 downto 0);
        reg_we: STD_LOGIC;
        is_store_inst: STD_LOGIC;
        funct3: STD_LOGIC_VECTOR(2 downto 0);
        alu_out: STD_LOGIC_VECTOR(31 downto 0);
        branch_en: STD_LOGIC;
        branch_adder_result: STD_LOGIC_VECTOR(31 downto 0);
        jump: STD_LOGIC;
    end record;

    type MEM_WB is record
        pc: STD_LOGIC_VECTOR(31 downto 0);
        rd: STD_LOGIC_VECTOR(4 downto 0);
        reg_data_src: STD_LOGIC_VECTOR(1 downto 0);
        reg_we: STD_LOGIC;
        funct3: STD_LOGIC_VECTOR(2 downto 0);
        immediate: STD_LOGIC_VECTOR(31 downto 0);
        alu_out: STD_LOGIC_VECTOR(31 downto 0);
    end record;

    signal clk_90 : STD_LOGIC;
    signal clk_25 : STD_LOGIC;

    signal IF_ID_in: IF_ID;
    signal IF_ID_out: IF_ID;

    signal ID_EX_in: ID_EX;
    signal ID_EX_out: ID_EX;

    signal EX_MEM_in : EX_MEM;
    signal EX_MEM_out : EX_MEM;

    signal MEM_WB_in: MEM_WB;
    signal MEM_WB_out : MEM_WB;

    signal pc_reg: STD_LOGIC_VECTOR(31 downto 0);
    signal next_pc: STD_LOGIC_VECTOR(31 downto 0);

    signal inst_ram_out: STD_LOGIC_VECTOR(31 downto 0);
    signal inst_ram_en: STD_LOGIC;
    signal stall_pipeline: STD_LOGIC;
    signal flush_pipeline: STD_LOGIC;
    signal flush_delayed: STD_LOGIC;
    signal data_mem_out: STD_LOGIC_VECTOR(31 downto 0);
    signal branch_adder_result: STD_LOGIC_VECTOR(31 downto 0);
    signal take_branch: STD_LOGIC;
    signal alu_out: STD_LOGIC_VECTOR(31 downto 0);
    signal imm_sel: std_logic_vector (2 downto 0);
    signal data_ram_we: STD_LOGIC_VECTOR(3 downto 0);
    signal ram_data_in: STD_LOGIC_VECTOR(31 downto 0);
    signal reg_data_in: STD_LOGIC_VECTOR(31 downto 0);
    signal alu_a: STD_LOGIC_VECTOR(31 downto 0);
    signal alu_b: STD_LOGIC_VECTOR(31 downto 0);
    signal alu_shamt: STD_LOGIC_VECTOR(4 downto 0);
    signal mem_writeback_data: STD_LOGIC_VECTOR(31 downto 0);
    signal forward_A: STD_LOGIC_VECTOR(1 downto 0);
    signal forward_B: STD_LOGIC_VECTOR(1 downto 0);
    signal forwarded_rs2: STD_LOGIC_VECTOR(31 downto 0);
    signal forwarded_rs1: STD_LOGIC_VECTOR(31 downto 0);

    signal vram_we: STD_LOGIC;
    signal vga_status: STD_LOGIC := '0'; --0: free to change buffer, 1: busy reading the screen
    signal swap_trigger: STD_LOGIC := '0';

    signal btn_reg: STD_LOGIC_VECTOR(3 downto 0);

    signal loader_address: STD_LOGIC_VECTOR(11 downto 0);
    signal inst_ram_we: STD_LOGIC_VECTOR(3 downto 0);
    signal inst_ram_address: STD_LOGIC_VECTOR(11 downto 0);
    signal inst_data_in: STD_LOGIC_VECTOR(31 downto 0);

    signal rst: STD_LOGIC;

    component clk_wiz_0 is
        port (
            clk_in1  : in  STD_LOGIC;
            clk_out1 : out STD_LOGIC;
            clk_out2 : out STD_LOGIC
        );
    end component;

begin

    clk_wiz_inst: clk_wiz_0
        port map(
            clk_in1 => clk, --Zybo Z7's 125 MHz clock
            clk_out1 => clk_90, --CPU's 90 MHz clock
            clk_out2 => clk_25 -- VGA controller's 25.2 MHz clock 
        );

    rst <= rst_btn or prog_mode;

    pipeline_registers: process(clk_90)
    begin
        if rising_edge(clk_90) then
            if rst = '1' then
                pc_reg <= (others => '0');
                IF_ID_out.pc <= (others => '0');
                
                ID_EX_out.reg_we <= '0';
                EX_MEM_out.reg_we <= '0';
                MEM_WB_out.reg_we <= '0';
                ID_EX_out.is_store_inst <= '0';
                flush_delayed <= '0';
            else
                
                flush_delayed <= flush_pipeline; 

                if stall_pipeline = '0' or flush_pipeline = '1' then
                    pc_reg <= next_pc;
                    IF_ID_out.pc <= pc_reg;
                end if;

                if stall_pipeline = '1' or flush_pipeline = '1' or flush_delayed = '1' then
                    ID_EX_out <= ID_EX_in;
                    
                    ID_EX_out.reg_we <= '0';
                    ID_EX_out.branch_en <= '0';
                    ID_EX_out.jump <= '0';
                    ID_EX_out.is_store_inst <= '0';
                else
                    ID_EX_out <= ID_EX_in;
                end if;

                if flush_pipeline = '1' then
                    EX_MEM_out <= EX_MEM_in;
                    
                    EX_MEM_out.reg_we <= '0';
                    EX_MEM_out.branch_en <= '0';
                    EX_MEM_out.jump <= '0';
                    EX_MEM_out.is_store_inst <= '0';
                else
                    EX_MEM_out <= EX_MEM_in;
                end if;

                MEM_WB_out <= MEM_WB_in;
            end if;
        end if;
    end process;

    program_loader: entity work.program_loader
     port map(
        clk => clk_90,
        prog_mode => prog_mode,
        rx => rx,
        instruction => inst_data_in,
        address => loader_address,
        we => inst_ram_we
    );


    ---------- IF STAGE ----------
    inst_ram_en <= not stall_pipeline;
    inst_ram_address <= pc_reg(13 downto 2) when prog_mode = '0' else loader_address;
    instruction_ram: entity work.ram
     generic map(
        ADDRESS_WIDTH => 12
    )
     port map(
        clk => clk_90,
        en => inst_ram_en,
        write_en => inst_ram_we,
        address => inst_ram_address,
        data_in => inst_data_in,
        data_out => inst_ram_out
    );

    IF_ID_out.instruction <= x"00000013" when (flush_delayed = '1' or flush_pipeline = '1') else inst_ram_out;
    

    ---------- ID STAGE ----------

    reg_file: entity work.reg_file
     generic map(
        ADDRESS_WIDTH => 5,
        DATA_WIDTH => 32
    )
     port map(
        clk => clk_90,
        rs1 => IF_ID_out.instruction(19 downto 15),
        rs2 => IF_ID_out.instruction(24 downto 20),
        rd => MEM_WB_out.rd,
        we => MEM_WB_out.reg_we,
        data_in => reg_data_in,
        reg_out1 => ID_EX_in.reg_out1,
        reg_out2 => ID_EX_in.reg_out2
    );

    control_unit: entity work.control_unit
     port map(
        instruction => IF_ID_out.instruction,
        imm_sel => imm_sel,
        ALU_src1 => ID_EX_in.ALU_src1,
        ALU_src2 => ID_EX_in.ALU_src2,
        branch_add_src => ID_EX_in.branch_add_src,
        branch_en => ID_EX_in.branch_en,
        ALU_op => ID_EX_in.ALU_op,
        sub_arShift => ID_EX_in.sub_arShift,
        jump => ID_EX_in.jump,
        reg_data_src => ID_EX_in.reg_data_src,
        reg_we => ID_EX_in.reg_we,
        is_store_inst => ID_EX_in.is_store_inst
    );

    imm_gen_unit: entity work.imm_gen_unit
     port map(
        instruction => IF_ID_out.instruction,
        imm_sel => imm_sel,
        immediate => ID_EX_in.immediate
    );

    ID_EX_in.pc <= IF_ID_out.pc;
    ID_EX_in.funct3 <= IF_ID_out.instruction(14 downto 12);
    ID_EX_in.rs1 <= IF_ID_out.instruction(19 downto 15);
    ID_EX_in.rs2 <= IF_ID_out.instruction(24 downto 20);
    ID_EX_in.rd <= IF_ID_out.instruction(11 downto 7);
    ID_EX_in.opcode <= IF_ID_out.instruction(6 downto 2);


    ---------- EX STAGE ----------
     hazard_detection_unit: entity work.hazard_detection_unit
     port map(
        IF_ID_opcode => IF_ID_out.instruction(6 downto 2),
        ID_EX_opcode => ID_EX_out.opcode,
        ID_EX_rd => ID_EX_out.rd,
        IF_ID_rs1 => IF_ID_out.instruction(19 downto 15),
        IF_ID_rs2 => IF_ID_out.instruction(24 downto 20),
        stall_pipeline => stall_pipeline
    );

    forwarding_unit: entity work.forwarding_unit
     port map(
        EX_MEM_reg_we => EX_MEM_out.reg_we,
        MEM_WB_reg_we => MEM_WB_out.reg_we,
        ID_EX_rs1 => ID_EX_out.rs1,
        ID_EX_rs2 => ID_EX_out.rs2,
        EX_MEM_rd => EX_MEM_out.rd,
        MEM_WB_rd => MEM_WB_out.rd,
        ex_stage_opcode => ID_EX_out.opcode,
        forward_A => forward_A,
        forward_B => forward_B
    );

    alu_input_selection_proc: process(all)
        variable ex_mem_data: STD_LOGIC_VECTOR(31 downto 0);
    begin
        -- If the instruction in EX/MEM is LUI (reg_data_src = "10"), forward its immediate
        --If it's JAL (reg_data_src = "11"), forward the pc value
        --otherwise forward the ALU result.
        if EX_MEM_out.reg_data_src = "10" then
            ex_mem_data := EX_MEM_out.immediate;
        elsif EX_MEM_out.reg_data_src = "11" then
            ex_mem_data := STD_LOGIC_VECTOR(unsigned(EX_MEM_out.pc) + 4); -- For JAL/JALR
        else
            ex_mem_data := EX_MEM_out.alu_out;
        end if;

        case forward_A is
            when "01" => forwarded_rs1 <= ex_mem_data; -- forwarded value from EX_MEM register
            --forwarded value from WB stage (reg_data_in could be the ALU's output, an immediate, data from memory or the PC value, depending on the instruction)
            when "10" => forwarded_rs1 <= reg_data_in; 
            when others => forwarded_rs1 <= ID_EX_out.reg_out1; -- regular ALU insput selection
        end case;

        case forward_B is
            when "01" => forwarded_rs2 <= EX_MEM_out.alu_out;
            when "10" => forwarded_rs2 <= reg_data_in;
            when others => forwarded_rs2 <= ID_EX_out.reg_out2; 
        end case;
    end process;

    alu_a <= forwarded_rs1 when ID_EX_out.ALU_src1 = '0' else ID_EX_out.pc;
    alu_b <= forwarded_rs2 when ID_EX_out.ALU_src2 = '0' else ID_EX_out.immediate;
    alu_shamt <= ID_EX_out.reg_out2(4 downto 0) when ID_EX_out.ALU_src2 = '0' else ID_EX_out.immediate(4 downto 0);

    alu: entity work.alu
     port map(
        a => alu_a,
        b => alu_b,
        op => ID_EX_out.ALU_op,
        sub_arShift => ID_EX_out.sub_arShift,
        shamt => alu_shamt,
        result => alu_out
    );

    branch_adder_proc: process (all)
    begin
        if ID_EX_out.branch_add_src = '0' then
            branch_adder_result <=  STD_LOGIC_VECTOR(unsigned(ID_EX_out.immediate) + unsigned(forwarded_rs1)) and x"FFFFFFFE"; --set lsb to 0
        else
            branch_adder_result <= STD_LOGIC_VECTOR(unsigned(ID_EX_out.immediate) + unsigned(ID_EX_out.pc));
        end if;
    end process;

    EX_MEM_in.reg_out2 <= forwarded_rs2;
    EX_MEM_in.alu_out <= alu_out;
    EX_MEM_in.pc <= ID_EX_out.pc;
    EX_MEM_in.immediate <= ID_EX_out.immediate;
    EX_MEM_in.rd <=ID_EX_out.rd;
    EX_MEM_in.reg_data_src <= ID_EX_out.reg_data_src;
    EX_MEM_in.reg_we <= ID_EX_out.reg_we;
    EX_MEM_in.is_store_inst <= ID_EX_out.is_store_inst;
    EX_MEM_in.funct3 <= ID_EX_out.funct3;
    EX_MEM_in.branch_en <= ID_EX_out.branch_en;
    EX_MEM_in.branch_adder_result <= branch_adder_result;
    EX_MEM_in.jump <= ID_EX_out.jump;

    ---------- MEM STAGE ----------
    branch_condition_unit: entity work.branch_condition_unit
     port map(
        funct3 => EX_MEM_out.funct3,
        ALUout => EX_MEM_out.alu_out,
        en => EX_MEM_out.branch_en,
        take_branch => take_branch
    );

    branch_resolution: process (all)
    begin
        if take_branch = '1' or EX_MEM_out.jump = '1' then
            next_pc <= EX_MEM_out.branch_adder_result;
            flush_pipeline <= '1'; 
        else
            next_pc <= STD_LOGIC_VECTOR(unsigned(pc_reg) + 4);
            flush_pipeline <= '0'; 
        end if;
    end process;

    store_alignment_unit: entity work.store_alignment_unit
     port map(
        funct3 => EX_MEM_out.funct3,
        alu_out => EX_MEM_out.alu_out,
        reg_out2 => EX_MEM_out.reg_out2,
        is_store_inst => EX_MEM_out.is_store_inst,
        ram_data_in => ram_data_in,
        data_ram_we => data_ram_we,
        vram_we => vram_we
    );

    data_ram: entity work.ram
     generic map(
        ADDRESS_WIDTH => 12
    )
     port map(
        clk => clk_90,
        en => '1',
        write_en => data_ram_we,
        address => EX_MEM_out.alu_out(13 downto 2),
        data_in => ram_data_in,
        data_out => data_mem_out
    );
    
    -- Store instructions targeting FRAMEBUFFER_CONTROL_ADDRESS toggle the active framebuffer
    swap_trigger <= '1' when EX_MEM_out.is_store_inst = '1' and EX_MEM_out.alu_out = FRAMEBUFFER_CONTROL_ADDRESS else '0';

    video_subsystem: entity work.video_subsystem
     port map(
        clk_90 => clk_90,
        clk_25 => clk_25,
        rst => rst,
        vram_we => vram_we,
        write_address => EX_MEM_out.alu_out(17 downto 0),
        vram_data_in => ram_data_in(7 downto 0),
        swap_trigger => swap_trigger,
        hsync => hsync,
        vsync => vsync,
        vga_status => vga_status,
        r => r,
        g => g,
        b => b
    );


    MEM_WB_in.pc <= EX_MEM_out.pc;
    MEM_WB_in.rd <= EX_MEM_out.rd;
    MEM_WB_in.reg_data_src <= EX_MEM_out.reg_data_src;
    MEM_WB_in.reg_we <= EX_MEM_out.reg_we;
    MEM_WB_in.alu_out <= EX_MEM_out.alu_out;
    MEM_WB_in.immediate <= EX_MEM_out.immediate;


    ---------- WB STAGE ----------
    data_loading_unit: entity work.data_loading_unit
     port map(
        data_mem_out => data_mem_out,
        byte_offset => MEM_WB_out.alu_out(1 downto 0),
        funct3 => MEM_WB_out.funct3,
        mem_writeback_data => mem_writeback_data
    );

     --Determines register file input
    reg_input_proc: process(all)
    begin
        case MEM_WB_out.reg_data_src is
            when "00" => reg_data_in <= MEM_WB_out.alu_out;

            when "01" => 
                if MEM_WB_out.alu_out = VGA_STATUS_ADDRESS then
                    reg_data_in <= (31 downto 1 => '0') & vga_status;
                elsif MEM_WB_out.alu_out = BUTTON_REG_ADDRESS then
                    reg_data_in <= x"0000000" & btn_reg;
                else
                    reg_data_in <= mem_writeback_data;
                end if;

            when "10" => reg_data_in <= MEM_WB_out.immediate;
            when others => reg_data_in <= STD_LOGIC_VECTOR(unsigned(MEM_WB_out.pc) + 4);
        end case;
    end process;


    button_debouncers: for i in 0 to 3 generate
        debouncer_synchronizer: entity work.debouncer_synchronizer
            port map(
                    clk => clk_90,
                    rst => rst,
                    btn_in => raw_btn_input(i),
                    btn_state => btn_reg(i)
                );
    end generate button_debouncers;

end rtl;
