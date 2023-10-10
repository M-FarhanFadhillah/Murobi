@extends('layouts.tempNav')
@section('container')
<div class="row">
  <div class="col"><h3><i class="fa-solid fa-wallet"></i> Laporan Keuangan Masjid A</h3></div>
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
            <div class="col-auto"><button type="button" class="btn btn-outline-danger"><i class="fa-solid fa-plus"></i> Tambah Pemasukan/Pengeluaran</button></div>
        </div>
    </div>
</div>
<div class="container">
    <table class="table text-center">
        <thead>
            <th scope="col">Tanggal</th>
            <th scope="col">Keterangan</th>
            <th scope="col">Debit</th>
            <th scope="col">Kredit</th>
            <th scope="col">Saldo</th>
        </thead>
        <tbody class="table-group-divider">
            <tr>
                <td>03 September 2023</td>
                <td>Saldo Awal</td>
                <td></td>
                <td></td>
                <td>Rp10.000.000</td>
            </tr>
            <tr>
                <td>04 September 2023</td>
                <td>Pembelian Semen 5 Sak</td>
                <td></td>
                <td>Rp1.000.000</td>
                <td>Rp9.000.000</td>
            </tr>
            <tr>
                <td>06 September 2023</td>
                <td>Infaq Sholat Jumat</td>
                <td>Rp1.250.000</td>
                <td></td>
                <td>Rp10.250.000</td>
            </tr>
        </tbody>
    </table> 
</div> 

@endsection