{{-- @dd($lapkeu) --}}
@extends('layouts.tempNav')
@section('container')
<div class="row">
  <div class="col"><h3><i class="fa-solid fa-wallet"></i> Laporan Keuangan Masjid {{ $data->masjid_name }}</h3></div>
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
            <div class="col-auto"><button type="button" class="btn btn-outline-danger" data-bs-toggle="modal" data-bs-target="#addCashflow"><i class="fa-solid fa-plus"></i> Tambah Pemasukan/Pengeluaran</button></div>
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
                <td>Rp {{ $data->saldo_awal }}</td>
            </tr>
            @foreach ($lapkeu as $item)
            <tr>
                <td>{{ $item->date }}</td>
                <td>{{ $item->note }}</td>
                <td>{{ ($item->cashflow === 0) ? 'Rp '. $item->nominal : '' }}</td>
                <td>{{ ($item->cashflow === 1) ? 'Rp '. $item->nominal : '' }}</td>
                <td>
                    @php
                    $result = ($item->cashflow === 0) ? $item->masjid->kas + $item->nominal : $item->masjid->kas - $item->nominal;
                    @endphp
                    Rp {{ $result }}
                </td>
            </tr>
            @endforeach
        </tbody>
    </table> 
</div> 
{{-- Modal Tambah Banner --}}
<div class="modal fade" id="addCashflow" tabindex="-1" aria-labelledby="addCashflowLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
      <div class="modal-content">
        <div class="modal-header">
          <h1 class="modal-title fs-5" id="addCashflowLabel">Tambah Arus Kas</h1>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
            <form>
              <div class="mb-3">
                <label for="InputMasjid" class="form-label">Lokasi Masjid</label>
                <input class="form-control" type="text" placeholder="{{ $data->masjid_name }}" aria-label="Disabled input example" disabled>
              </div>
              <div class="mb-3">
                <label for="InputKategori" class="form-label">Arus Kas</label>
                <select class="form-select" aria-label="Default select example">
                    <option value="0">Debit (Uang Masuk)</option>
                    <option value="1">Kredit (Uang Keluar)</option>
                </select>
            </div>
            <div class="mb-3">
              <label for="InputKeterangan" class="form-label">Keterangan</label>
              <input type="text" class="form-control" id="InputKeterangan" aria-describedby="keteranganHelp">
            </div>
            <div class="mb-3">
              <label for="InputTanggal" class="form-label">Tanggal</label>
              <input type="date" class="form-control" id="InputTanggal" aria-describedby="tanggalHelp">
            </div>
            <div class="mb-3">
              <label for="InputNominal" class="form-label">Nominal</label>
              <input type="number" class="form-control" id="InputNominal" aria-describedby="nominalHelp">
            </div>
                <button type="submit" class="btn btn-primary">Submit</button>
              </form>
        </div>
      </div>
    </div>
</div>
@endsection