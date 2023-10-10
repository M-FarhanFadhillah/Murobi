@extends('layouts.tempNav')
@section('container')
<div class="row">
  <div class="col-6 .col-sm-4"><h3><i class="fa-solid fa-user-group"></i> Pengguna</h3></div>
</div>
<hr>
<div class="row">
  <div class="col">
      <div class="card text-center">
          <div class="card-header">
              <h3><i class="fa-solid fa-user"></i></h3>
          </div>
          <div class="card-body">
            <a class="link-body-emphasis text-decoration-none" href="/listUser"><h5 class="card-title"> PENGGUNA <i class="fa-solid fa-arrow-right fa-fade"></i></h5></a>
          </div>
          <div class="card-footer text-body-secondary">
            112 Pengguna
          </div>
      </div>
  </div>
  <div class="col">
      <div class="card text-center">
          <div class="card-header">
            <h3><i class="fa-solid fa-address-card"></i></h3>
          </div>
          <div class="card-body">
            <a href="/validateRegist" class="link-body-emphasis text-decoration-none"><h5 class="card-title"> VALIDASI PENDAFTAR <i class="fa-solid fa-arrow-right fa-fade"></i></h5></a>
          </div>
          <div class="card-footer text-body-secondary">
            2 Pendaftar Baru
          </div>
      </div>
  </div>
  {{-- <div class="col">
      <div class="card text-center">
          <div class="card-header">
            <h3><i class="fa-solid fa-circle-dollar-to-slot"></i></h3>
          </div>
          <div class="card-body">
            <a href="#" class="link-body-emphasis text-decoration-none"><h5 class="card-title">ZISWAF <i class="fa-solid fa-arrow-right fa-fade"></i></h5></a>
          </div>
          <div class="card-footer text-body-secondary">
            15 Total Donasi
          </div>
      </div>
  </div> --}}
</div>
@endsection