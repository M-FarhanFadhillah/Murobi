@extends('layouts.tempNav')
@section('container')
<h3 class="mb-4"><i class="fa-solid fa-mosque"></i> Daftar Masjid</h3>
<div class="row">
    <div class="col">
        <a href="#"><button type="button" class="btn btn-outline-warning" data-bs-toggle="modal" data-bs-target="#addMasjid"><i class="fa-solid fa-plus"></i> Tambah Masjid</button></a>
    </div>
    <div class="col-3">
        <form action="/listmasjid">
            <div class="input-group mb-3">
                <input type="text" class="form-control" placeholder="Cari Masjid..." name="search" value="{{ request('search') }}">
                <button class="btn btn-outline-secondary" type="submit">Cari</button>
            </div>
        </form>
    </div>
</div>
<hr>
<div class="container">
    <table class="table text-center">
        <thead>
            <th scope="col">ID</th>
            <th scope="col">Nama Masjid</th>
            <th scope="col">Aksi</th>
        </thead>
        <tbody class="table-group-divider">
            @foreach ($listMasjid as $item)
            <tr>
                <td>{{ $item->id }}</td>
                <td>{{ $item->masjid_name }}</td>
                <td>
                    <div class="btn-group btn-group-sm" role="group" aria-label="Small button group">
                        <a href="#"data-bs-toggle="modal" data-bs-target="#infoMasjid-{{ $item->id }}"><button type="button" class="btn btn-outline-info" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tampilkan Detail Informasi"><i class="fa-solid fa-info"></i></button></a>
                        <a href="#"><button type="button" class="btn btn-outline-danger" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Hapus Masjid"><i class="fa-solid fa-trash"></i></button></a>
                    </div>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table> 
</div> 
{{ $listMasjid->links() }}
{{-- Modal Tambah Masjid --}}
<div class="modal fade" id="addMasjid" tabindex="-1" aria-labelledby="addMasjidLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
      <div class="modal-content">
        <div class="modal-header">
          <h1 class="modal-title fs-5" id="addMasjidLabel">Daftarkan Masjid Baru</h1>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
            <form>
                <div class="mb-3">
                  <label for="InputNameMasjid" class="form-label">Nama Masjid</label>
                  <input type="text" class="form-control" id="InputNameMasjid" aria-describedby="nameHelp">
                </div>
                <div class="mb-3">
                  <label for="InputAlamat" class="form-label">Alamat</label>
                  <input type="text" class="form-control" id="InputAlamat" aria-describedby="AlamatHelp">
                </div>
                <div class="mb-3">
                  <label for="InputKetuaMasjid" class="form-label">Ketua Masjid</label>
                  <input type="text" class="form-control" id="InputKetuaMasjid" aria-describedby="KetuaMasjidHelp">
                </div>
                <div class="mb-3">
                  <label for="InputKapasitas" class="form-label">Kapasitas Masjid</label>
                  <input type="number" class="form-control" id="InputKapasitas" aria-describedby="KapasitasHelp">
                </div>
                <div class="mb-3">
                  <label for="InputSaldo" class="form-label">Saldo Saat ini</label>
                  <input type="number" class="form-control" id="InputSaldo" aria-describedby="SaldoHelp">
                </div>
                <div class="mb-3">
                  <label for="InputKas" class="form-label">Kas Saat ini</label>
                  <input type="number" class="form-control" id="InputKas" aria-describedby="KasHelp">
                </div>
                <div class="mb-3">
                    <label for="formFile" class="form-label">Foto Cover Masjid</label>
                    <input class="form-control" type="file" id="formFile">
                  </div>
                <button type="submit" class="btn btn-primary">Submit</button>
              </form>
        </div>
      </div>
    </div>
</div>
{{-- Modal Details --}}
@foreach ($data as $item)
<div class="modal fade" id="infoMasjid-{{ $item->id }}" tabindex="-1" aria-labelledby="infoMasjidLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="infoMasjidLabel">Detail Informasi</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            
            <div class="col text-center">
                <img src="https://github.com/mdo.png" alt="Foto Profil" width="150">
            </div>
            <div class="row">
                <div class="col">
                    <table class="table">
                        <thead>
                        </thead>
                        <tbody>
                            <tr>
                                <th scope="row">ID</th>
                                <td>{{ $item->id }}</td>
                            </tr>
                            <tr>
                                <th scope="row">Nama Masjid</th>
                                <td>{{ $item->masjid_name }}</td>
                            </tr>
                            <tr>
                                <th scope="row">Alamat Masjid</th>
                                <td>{{ $item->alamat }}</td>
                            </tr>
                            <tr>
                                <th scope="row">Ketua Masjid</th>
                                <td>{{ $item->ketua_masjid }}</td>
                            </tr>
                            <tr>
                                <th scope="row">Kapasitas</th>
                                <td>{{ $item->kapasitas }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
@endforeach 
@endsection