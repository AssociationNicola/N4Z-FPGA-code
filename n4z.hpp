/// SelectIO driver
///
/// (c) Koheron

#ifndef __Nicola_4Z_DRIVER__
#define __Nicola_4Z_DRIVER__

#include <context.hpp>

namespace Xadc_regs {
    constexpr uint32_t set_chan = 0x324;
    constexpr uint32_t avg_en = 0x32C;
    constexpr uint32_t read = 0x240;
    constexpr uint32_t config0 = 0x300;
}

namespace Fifo_regs {
    constexpr uint32_t tdfr = 0x08;
    constexpr uint32_t tdfv = 0x0C;
    constexpr uint32_t tdfd = 0x10;
    constexpr uint32_t rdfr = 0x18;
    constexpr uint32_t rdfo = 0x1C;
    constexpr uint32_t rdfd = 0x20;
    constexpr uint32_t rlr = 0x24;
}

constexpr uint32_t ARR_SIZE = 1200;





class Nicola4Z
{
  public:
    Nicola4Z(Context& ctx)
    : ctl(ctx.mm.get<mem::control>())
    , sts(ctx.mm.get<mem::status>())
    , xadc(ctx.mm.get<mem::xadc>())
    , data_fifo_map(ctx.mm.get<mem::data_fifo>())
    , tx_fifo_map(ctx.mm.get<mem::tx_fifo>())
    , ave_i_fifo_map(ctx.mm.get<mem::ave_i_fifo>())
    , ave_q_fifo_map(ctx.mm.get<mem::ave_q_fifo>())


    {
    }
    uint32_t xadc_read(uint32_t channel) {
        return xadc.read_reg(Xadc_regs::read + 4 * channel);
    }


    uint64_t get_dna() {
        return sts.read<reg::dna, uint64_t>();
    }

    uint32_t get_data() {
        return sts.read<reg::data>();
    }

    uint32_t get_display_i() {
        return sts.read<reg::display_i>();
    }


    uint32_t get_max_amplitude() {
        return sts.read<reg::max_amplitude>();
    }

    uint32_t get_average_amplitude() {
        return sts.read<reg::average_amplitude>();
    }




    uint32_t get_ck_inner_io() {
        return sts.read<reg::ck_inner_io>();
    }

    void set_led(uint32_t value) {
        ctl.write<reg::led>(value);
    }


	 void set_ssb_tx_frequency(uint32_t value) {
        ctl.write<reg::ssb_tx_frequency>(value);
    }
	

    void set_display_o(uint32_t value) {
        ctl.write<reg::display_o>(value);
    }

///    void set_lcd(uint32_t value) {
///        ctl.write<reg::lcd>(value);
///    }

	
    void set_average(uint32_t value) {
        ctl.write<reg::average>(value);
    }

    void set_user_io(uint32_t value) {
        ctl.write<reg::user_io>(value);
    }

    void set_control(uint32_t value) {
        ctl.write<reg::control>(value);
    }


    // data FIFO

    uint32_t get_fifo_occupancy() {
        return data_fifo_map.read<Fifo_regs::rdfo>();
    }

    uint32_t get_tx_fifo_vacancy() {
        return tx_fifo_map.read<Fifo_regs::tdfv>();
    }


    void reset_fifo() {
        data_fifo_map.write<Fifo_regs::rdfr>(0x000000A5);
    }

    void reset_tx_fifo() {
        tx_fifo_map.write<Fifo_regs::tdfr>(0x000000A5);
    }

    uint32_t read_fifo() {
        return data_fifo_map.read<Fifo_regs::rdfd>();
    }

    void write_fifo(int32_t val) {
        tx_fifo_map.write<Fifo_regs::tdfd>(val);
    }



    uint32_t get_fifo_length() {
        return (data_fifo_map.read<Fifo_regs::rlr>() & 0x3FFFFF) >> 2;
    }

    void wait_for(uint32_t n_pts) {
        do {} while (get_fifo_length() < n_pts);
    }

    auto& read_data() {
        wait_for(ARR_SIZE);
        for (unsigned int i=0; i < ARR_SIZE; i++) {
            data[i] = read_fifo();
        }
        return data;
    }

    auto& read_24_data() {
        wait_for(24);
        for (unsigned int i=0; i < 24; i++) {
            data[i] = read_fifo();
        }
        return data;
    }



    void write_data(const std::array<int32_t, ARR_SIZE>& data) {
        for (unsigned int i=0; i < ARR_SIZE; i++) {
            write_fifo(data[i]);
        }
    }


    auto& read_available_data() {
        uint32_t no_available=get_fifo_length();
        for (unsigned int i=0; i < no_available; i++) {
            data[i] = read_fifo();
        }
        for (unsigned int i=no_available; i < ARR_SIZE-1; i++) {
            data[i] = 0;
        }
        data[ARR_SIZE-1] = no_available;

        return data;
    }


//Now add fifo for <Iave>
    uint32_t get_Iave_fifo_occupancy() {
        return ave_i_fifo_map.read<Fifo_regs::rdfo>();
    }


    void reset_Iave_fifo() {
        ave_i_fifo_map.write<Fifo_regs::rdfr>(0x000000A5);
    }

   uint32_t read_Iave_fifo() {
        return ave_i_fifo_map.read<Fifo_regs::rdfd>();
    }



    uint32_t get_Iave_fifo_length() {
        return (ave_i_fifo_map.read<Fifo_regs::rlr>() & 0x3FFFFF) >> 2;
    }

    void wait_for_Iave_n_pts(uint32_t n_pts) {
        do {} while (get_Iave_fifo_length() < n_pts);
    }

    auto& read_Iave() {
        wait_for_Iave_n_pts(ARR_SIZE);
        for (unsigned int i=0; i < ARR_SIZE; i++) {
            data[i] = read_Iave_fifo();
        }
        return data;
    }

    auto& read_24_Iave() {
        wait_for_Iave_n_pts(24);
        for (unsigned int i=0; i < 24; i++) {
            data[i] = read_Iave_fifo();
        }
        return data;
    }




    auto& read_available_Iave() {
        uint32_t no_available=get_Iave_fifo_length();
        for (unsigned int i=0; i < no_available; i++) {
            data[i] = read_Iave_fifo();
        }
        for (unsigned int i=no_available; i < ARR_SIZE-1; i++) {
            data[i] = 0;
        }
        data[ARR_SIZE-1] = no_available;

        return data;
    }

//and <Qave>	
    uint32_t get_Qave_fifo_occupancy() {
        return ave_q_fifo_map.read<Fifo_regs::rdfo>();
    }


    void reset_Qave_fifo() {
        ave_q_fifo_map.write<Fifo_regs::rdfr>(0x000000A5);
    }

   uint32_t read_Qave_fifo() {
        return ave_q_fifo_map.read<Fifo_regs::rdfd>();
    }



    uint32_t get_Qave_fifo_length() {
        return (ave_q_fifo_map.read<Fifo_regs::rlr>() & 0x3FFFFF) >> 2;
    }

    void wait_for_Qave_n_pts(uint32_t n_pts) {
        do {} while (get_Qave_fifo_length() < n_pts);
    }

    auto& read_Qave() {
        wait_for_Qave_n_pts(ARR_SIZE);
        for (unsigned int i=0; i < ARR_SIZE; i++) {
            data[i] = read_Qave_fifo();
        }
        return data;
    }

    auto& read_24_Qave() {
        wait_for_Qave_n_pts(24);
        for (unsigned int i=0; i < 24; i++) {
            data[i] = read_Qave_fifo();
        }
        return data;
    }




    auto& read_available_Qave() {
        uint32_t no_available=get_Qave_fifo_length();
        for (unsigned int i=0; i < no_available; i++) {
            data[i] = read_Qave_fifo();
        }
        for (unsigned int i=no_available; i < ARR_SIZE-1; i++) {
            data[i] = 0;
        }
        data[ARR_SIZE-1] = no_available;

        return data;
    }
	
  private:
    Memory<mem::control>& ctl;
    Memory<mem::status>& sts;
    Memory<mem::xadc>& xadc;
    Memory<mem::data_fifo>& data_fifo_map;
    Memory<mem::tx_fifo>& tx_fifo_map;
    Memory<mem::ave_i_fifo>& ave_i_fifo_map;
    Memory<mem::ave_q_fifo>& ave_q_fifo_map;

    std::array<uint32_t, ARR_SIZE> data;

};
#endif // __Nicola_4Z_DRIVER__
