@extends('layouts.tempNav')
@section('container')
<div class="row">
  <div class="col"><h3><i class="fa-solid fa-circle-dollar-to-slot"></i> Laporan ZISWAF Masjid A</h3></div>
</div>
<hr>
<div class="row">
    <div class="col">
        <div class="row g-3 align-items-center">
            <div class="col-auto">
                <select class="form-select" aria-label="Default select example">
                    <option selected>Pilih Awal Periode</option>
                    <option value="Januari">Januari</option>
                    <option value="Februari">Februari</option>
                    <option value="Maret">Maret</option>
                    <option value="April">April</option>
                    <option value="Mei">Mei</option>
                    <option value="Juni">Juni</option>
                    <option value="Juli">Juli</option>
                    <option value="Agustus">Agustus</option>
                    <option value="September">September</option>
                    <option value="Oktober">Oktober</option>
                    <option value="November">November</option>
                    <option value="Desember">Desember</option>
                  </select>
            </div>
            <div class="col-auto"><i class="fa-solid fa-arrow-right fa-beat-fade"></i></div>
            <div class="col-auto">
                <select class="form-select" aria-label="Default select example">
                    <option selected>Pilih Akhir Periode</option>
                    <option value="Januari">Januari</option>
                    <option value="Februari">Februari</option>
                    <option value="Maret">Maret</option>
                    <option value="April">April</option>
                    <option value="Mei">Mei</option>
                    <option value="Juni">Juni</option>
                    <option value="Juli">Juli</option>
                    <option value="Agustus">Agustus</option>
                    <option value="September">September</option>
                    <option value="Oktober">Oktober</option>
                    <option value="November">November</option>
                    <option value="Desember">Desember</option>
                  </select>
            </div>
            <div class="col-auto"><button type="button" class="btn btn-outline-info" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tampilkan"><i class="fa-solid fa-chevron-right"></i></button></div>
            <div class="col-auto"><button type="button" class="btn btn-outline-success"><i class="fa-solid fa-download"></i> Download Laporan</button></div>
        </div>
    </div>
</div>
<div class="container">
    <table class="table text-center">
        <thead>
            <th scope="col">ID Transanksi</th>
            <th scope="col">Nama</th>
            <th scope="col">Rekening</th>
            <th scope="col">Kategori</th>
            <th scope="col">Nominal</th>
            <th scope="col">Aksi</th>
        </thead>
        <tbody class="table-group-divider">
            <tr>
                <td>INF202310035717</td>
                <td>Syahril Fajri Pratama</td>
                <td>1140025535439 (Bank Mandiri)</td>
                <td>Infaq</td>
                <td>Rp 4.000.000</td>
                <td>
                    <div class="btn-group btn-group-sm" role="group" aria-label="Small button group">
                        <a href="#"><button type="button" class="btn btn-outline-info" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tampilkan Detail Informasi"><i class="fa-solid fa-list"></i></button></a>
                        <a href="#"><button type="button" class="btn btn-outline-primary" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Cetak Laporan"><i class="fa-solid fa-file-pdf"></i></button></a>
                    </div>
                </td>
            </tr>
        </tbody>
    </table> 
</div> 

@endsection