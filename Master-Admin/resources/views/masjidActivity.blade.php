@extends('layouts.tempNav')
@section('container')
<div class="row">
    <div class="col">
        <div class="d-flex flex-column flex-shrink-0 p-3 bg-body-tertiary">
            <a href="#"><button type="button" class="btn btn-outline-secondary"><i class="fas fa-arrow-left fa-sm fa-fw"></i> Kembali</button></a>
            <img src="/img/masjid.jpg" class="d-block w-100 mt-1" alt="Masjid">
            <h3 class="text-center mt-1">Masjid A</h3>
            <table class="table table-borderless">
                <tbody>
                    <tr>
                      <td>Kapasitas</td>
                      <td>: 1000 Orang</td>
                    </tr>
                    <tr>
                      <td>Kas Masjid</td>
                      <td>: Rp 70.000.000</td>
                    </tr>
                    <tr>
                      <td>Marbot</td>
                      <td>: Bapak Akhwan</td>
                    </tr>
                  </tbody>
            </table>
            <hr>
            <p class="text-center">Jl. Nangka, Sepang Jaya, Kec. Kedaton, Kota Bandar Lampung, Lampung 35141</p>
        </div>
    </div>
    <div class="col" style="overflow: auto">
        <table class="table text-center">
            <div class="row">
                <div class="col-sm-6 .col-sm-8"><h3>Kegiatan Masjid</h3></div>
                <div class="col text-end"><a href="#"><button type="button" class="btn btn-outline-warning"><i class="fa-solid fa-users-rays"></i> Tambah Kegiatan</button></a></div>
            </div>
            <thead>
                <th scope="col">ID</th>
                <th scope="col">Nama Kegiatan</th>
                <th scope="col">Kategori</th>
                <th scope="col">Aksi</th>
            </thead>
            <tbody class="table-group-divider">
                <tr>
                    <td>2057051017</td>            
                    <td>Yasinan Bersama</td>
                    <td>Kegiatan Besar</td>
                    <td>
                        <div class="btn-group btn-group-sm" role="group" aria-label="Small button group">
                            <a href="#"><button type="button" class="btn btn-outline-info" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tampilkan Detail Informasi"><i class="fa-solid fa-info"></i></button></a>
                            <a href="#"><button type="button" class="btn btn-outline-danger" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Hapus Kegiatan"><i class="fa-solid fa-trash"></i></button></a>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

@endsection