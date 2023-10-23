{{-- @dd($lapkeu) --}}
@extends('layouts.tempNav')
@section('container')
@if(session()->has('success'))
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        {{ session('success') }}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
@endif
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
                <td>{{ $data->created_at->format('d F Y') }}</td>
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
{{-- Modal Tambah Cashflow --}}
{{-- Updated --}}
<div class="modal fade" id="addCashflow" tabindex="-1" aria-labelledby="addCashflowLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
      <div class="modal-content">
        <div class="modal-header">
          <h1 class="modal-title fs-5" id="addCashflowLabel">Tambah Arus Kas</h1>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
            <form id="addCashflow" action="/lapkeu/{{ $data->id }}" method="POST" enctype="multipart/form-data">
              @csrf
              <div class="mb-3">
                <label for="InputMasjid" class="form-label">Lokasi Masjid</label>
                <input class="form-control" type="text" placeholder="{{ $data->masjid_name }}" disabled>
              </div>
              <div>
                <input class="form-control" type="hidden" required name="masjid_id" id="masjid_id" value="{{ $data->id }}">
              </div>
              <div class="mb-3">
                <label class="form-label">Arus Kas</label>
                <select type="number" name="cashflow" id="cashflow" class="form-select" >
                    <option value="0">Debit (Uang Masuk)</option>
                    <option value="1">Kredit (Uang Keluar)</option>
                </select>
            </div>
            <div class="mb-3 form-floating">
              <input name="note" id="note" type="text" class="form-control" required>
              <label>Keterangan</label>
            </div>
            <div class="mb-3">
              <label class="form-label">Tanggal</label>
              <input name="date" id="date" type="date" class="form-control" required>
            </div>
            <div class="mb-3 form-floating">
              <input type="number" class="form-control" id="nominal" name="nominal" required>
              <label>Nominal</label>
            </div>
                <button type="submit" class="btn btn-primary">Submit</button>
              </form>
        </div>
      </div>
    </div>
</div>
@endsection